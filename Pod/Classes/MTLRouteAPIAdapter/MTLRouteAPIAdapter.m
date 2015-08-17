//
//  MTLRouteAPIAdapter.m
//  Pods
//
//  Created by vlad gorbenko on 8/16/15.
//
//

#import "MTLRouteAPIAdapter.h"

#import "NSDictionary+MTLJSONKeyPath.h"

#import "EXTRuntimeExtensions.h"
#import "EXTScope.h"
#import "MTLJSONAdapter.h"
#import "MTLModel.h"
#import "MTLTransformerErrorHandling.h"
#import "MTLReflection.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"
#import "MTLValueTransformer.h"

#import "NSObject+API.h"

#import "APIRouter.h"

@implementation MTLRouteAPIAdapter

#pragma mark Serialization

- (NSDictionary *)JSONDictionaryFromModel:(id<MTLRouteJSONSerializing>)model action:(NSString *)action error:(NSError **)error {
    NSParameterAssert(model != nil);
    NSParameterAssert([model isKindOfClass:self.modelClass]);
    
    if (self.modelClass != model.class) {
        MTLRouteAPIAdapter *otherAdapter = (MTLRouteAPIAdapter *)[self JSONAdapterForModelClass:model.class action:action error:error];
        
        return [otherAdapter JSONDictionaryFromModel:model action:action error:error];
    }
    
    NSSet *propertyKeysToSerialize = [self serializablePropertyKeys:[NSSet setWithArray:self.JSONKeyPathsByPropertyKey.allKeys] forModel:model];
    
    NSDictionary *dictionaryValue = [model.dictionaryValue dictionaryWithValuesForKeys:propertyKeysToSerialize.allObjects];
    NSMutableDictionary *JSONDictionary = [[NSMutableDictionary alloc] initWithCapacity:dictionaryValue.count];
    
    __block BOOL success = YES;
    __block NSError *tmpError = nil;
    
    [dictionaryValue enumerateKeysAndObjectsUsingBlock:^(NSString *propertyKey, id value, BOOL *stop) {
        id JSONKeyPaths = self.JSONKeyPathsByPropertyKey[propertyKey];
        
        if (JSONKeyPaths == nil) return;
        
        NSValueTransformer *transformer = self.valueTransformersByPropertyKey[propertyKey];
        if ([transformer.class allowsReverseTransformation]) {
            // Map NSNull -> nil for the transformer, and then back for the
            // dictionaryValue we're going to insert into.
            if ([value isEqual:NSNull.null]) value = nil;
            
            if ([transformer respondsToSelector:@selector(reverseTransformedValue:success:error:)]) {
                id<MTLTransformerErrorHandling> errorHandlingTransformer = (id)transformer;
                
                value = [errorHandlingTransformer reverseTransformedValue:value success:&success error:&tmpError];
                
                if (!success) {
                    *stop = YES;
                    return;
                }
            } else {
                value = [transformer reverseTransformedValue:value] ?: NSNull.null;
            }
        }
        
        void (^createComponents)(id, NSString *) = ^(id obj, NSString *keyPath) {
            NSArray *keyPathComponents = [keyPath componentsSeparatedByString:@"."];
            
            // Set up dictionaries at each step of the key path.
            for (NSString *component in keyPathComponents) {
                if ([obj valueForKey:component] == nil) {
                    // Insert an empty mutable dictionary at this spot so that we
                    // can set the whole key path afterward.
                    [obj setValue:[NSMutableDictionary dictionary] forKey:component];
                }
                
                obj = [obj valueForKey:component];
            }
        };
        
        if ([JSONKeyPaths isKindOfClass:NSString.class]) {
            createComponents(JSONDictionary, JSONKeyPaths);
            
            [JSONDictionary setValue:value forKeyPath:JSONKeyPaths];
        }
        
        if ([JSONKeyPaths isKindOfClass:NSArray.class]) {
            for (NSString *JSONKeyPath in JSONKeyPaths) {
                createComponents(JSONDictionary, JSONKeyPath);
                
                [JSONDictionary setValue:value[JSONKeyPath] forKeyPath:JSONKeyPath];
            }
        }
    }];
    
    if (success) {
        return JSONDictionary;
    } else {
        if (error != NULL) *error = tmpError;
        
        return nil;
    }
}

- (id)modelFromJSONDictionary:(NSDictionary *)JSONDictionary action:(NSString *)action error:(NSError **)error {
    if ([self.modelClass respondsToSelector:@selector(classForParsingJSONDictionary:)]) {
        Class class = [self.modelClass classForParsingJSONDictionary:JSONDictionary];
        if (class == nil) {
            if (error != NULL) {
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Could not parse JSON", @""),
                                            NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No model class could be found to parse the JSON dictionary.", @"")};
                *error = [NSError errorWithDomain:MTLJSONAdapterErrorDomain code:MTLJSONAdapterErrorNoClassFound userInfo:userInfo];
            }
            return nil;
        }
        
        if (class != self.modelClass) {
            NSAssert([class conformsToProtocol:@protocol(MTLJSONSerializing)], @"Class %@ returned from +classForParsingJSONDictionary: does not conform to <MTLJSONSerializing>", class);
            MTLAPIAdapter *otherAdapter = [self JSONAdapterForModelClass:class action:(NSString *)action error:error];
            return [otherAdapter modelFromJSONDictionary:JSONDictionary action:action error:error];
        }
    }
    
    NSMutableDictionary *dictionaryValue = [[NSMutableDictionary alloc] initWithCapacity:JSONDictionary.count];
    
    for (NSString *propertyKey in [self.modelClass propertyKeys]) {
        id JSONKeyPaths = self.JSONKeyPathsByPropertyKey[propertyKey];
        if (JSONKeyPaths == nil) continue;
        id value;
        if ([JSONKeyPaths isKindOfClass:NSArray.class]) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            
            for (NSString *keyPath in JSONKeyPaths) {
                BOOL success;
                id value = [JSONDictionary mtl_valueForJSONKeyPath:keyPath success:&success error:error];
                
                if (!success) return nil;
                
                if (value != nil) dictionary[keyPath] = value;
            }
            
            value = dictionary;
        } else {
            BOOL success;
            value = [JSONDictionary mtl_valueForJSONKeyPath:JSONKeyPaths success:&success error:error];
            
            if (!success) return nil;
        }
        
        if (value == nil) continue;
        
        @try {
            NSValueTransformer *transformer = self.valueTransformersByPropertyKey[propertyKey];
            if (transformer != nil) {
                // Map NSNull -> nil for the transformer, and then back for the
                // dictionary we're going to insert into.
                if ([value isEqual:NSNull.null]) value = nil;
                
                if ([transformer respondsToSelector:@selector(transformedValue:success:error:)]) {
                    id<MTLTransformerErrorHandling> errorHandlingTransformer = (id)transformer;
                    
                    BOOL success = YES;
                    value = [errorHandlingTransformer transformedValue:value success:&success error:error];
                    
                    if (!success) return nil;
                } else {
                    value = [transformer transformedValue:value];
                }
                
                if (value == nil) value = NSNull.null;
            }
            
            dictionaryValue[propertyKey] = value;
        } @catch (NSException *ex) {
            NSLog(@"*** Caught exception %@ parsing JSON key path \"%@\" from: %@", ex, JSONKeyPaths, JSONDictionary);
            
            // Fail fast in Debug builds.
#if DEBUG
            @throw ex;
#else
            if (error != NULL) {
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: ex.description,
                                           NSLocalizedFailureReasonErrorKey: ex.reason,
                                           MTLJSONAdapterThrownExceptionErrorKey: ex
                                           };
                
                *error = [NSError errorWithDomain:MTLJSONAdapterErrorDomain code:MTLJSONAdapterErrorExceptionThrown userInfo:userInfo];
            }
            
            return nil;
#endif
        }
    }
    
    id model = [self.modelClass modelWithDictionary:dictionaryValue error:error];
    
    return [model validate:error] ? model : nil;
}

@end

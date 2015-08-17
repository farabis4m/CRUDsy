//
//  MTLAPIAdapter.m
//  Pods
//
//  Created by vlad gorbenko on 8/16/15.
//
//

#import "MTLAPIAdapter.h"

#import "APIRouter.h"

#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import <Mantle/NSDictionary+MTLJSONKeyPath.h>
#import <Mantle/EXTRuntimeExtensions.h>
#import <Mantle/EXTScope.h>
#import <Mantle/MTLReflection.h>

@implementation MTLAPIAdapter

#pragma mark Convenience methods

+ (id)modelOfClass:(Class)modelClass fromJSONDictionary:(NSDictionary *)JSONDictionary action:(NSString *)action error:(NSError **)error {
    MTLAPIAdapter *adapter = [[self alloc] initWithModelClass:modelClass action:action];
    adapter.routeClass = modelClass;
    return [adapter modelFromJSONDictionary:JSONDictionary action:action error:error];
}

+ (id)modelOfClass:(Class)modelClass routeClass:(Class)routeClass fromJSONDictionary:(NSDictionary *)JSONDictionary action:(NSString *)action depath:(NSString *)depth error:(NSError **)error {
    MTLAPIAdapter *adapter = [[self alloc] initWithModelClass:modelClass action:action];
    
    adapter.depth = depth;
    adapter.routeClass = routeClass;
    return [adapter modelFromJSONDictionary:JSONDictionary action:action error:error];
}

+ (id)modelOfClass:(Class)modelClass fromJSONDictionary:(NSDictionary *)JSONDictionary error:(NSError *__autoreleasing *)error {
    return [self modelOfClass:modelClass fromJSONDictionary:JSONDictionary action:nil error:error];
}

+ (NSArray *)modelsOfClass:(Class)modelClass fromJSONArray:(NSArray *)JSONArray action:(NSString *)action error:(NSError **)error {
    if (JSONArray == nil || ![JSONArray isKindOfClass:NSArray.class]) {
        if (error != NULL) {
            NSString *reasonErrorKey = [NSString stringWithFormat:NSLocalizedString(@"%@ could not be created because an invalid JSON array was provided: %@", @""), NSStringFromClass(modelClass), JSONArray.class];
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Missing JSON array", @""),
                                        NSLocalizedFailureReasonErrorKey: reasonErrorKey };
            *error = [NSError errorWithDomain:MTLJSONAdapterErrorDomain code:MTLJSONAdapterErrorInvalidJSONDictionary userInfo:userInfo];
        }
        return nil;
    }
    
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:JSONArray.count];
    for (NSDictionary *JSONDictionary in JSONArray){
        MTLModel *model = [self modelOfClass:modelClass fromJSONDictionary:JSONDictionary action:action error:error];
        if (model == nil) return nil;
        [models addObject:model];
    }
    return models;
}

+ (NSArray *)modelsOfClass:(Class)modelClass fromJSONArray:(NSArray *)JSONArray error:(NSError *__autoreleasing *)error {
    return [self modelsOfClass:modelClass fromJSONArray:JSONArray action:nil error:error];
}

+ (NSDictionary *)JSONDictionaryFromModel:(id<MTLRouteJSONSerializing>)model action:(NSString *)action error:(NSError **)error {
    MTLAPIAdapter *adapter = [[self alloc] initWithModelClass:model.class];
    return [adapter JSONDictionaryFromModel:model action:action error:error];
}

+ (NSDictionary *)JSONDictionaryFromModel:(id<MTLRouteJSONSerializing>)model error:(NSError *__autoreleasing *)error {
    return [self JSONDictionaryFromModel:model action:nil error:error];
}

+ (NSArray *)JSONArrayFromModels:(NSArray *)models action:(NSString *)action error:(NSError **)error {
    NSParameterAssert(models != nil);
    NSParameterAssert([models isKindOfClass:NSArray.class]);
    
    NSMutableArray *JSONArray = [NSMutableArray arrayWithCapacity:models.count];
    for (MTLModel<MTLRouteJSONSerializing> *model in models) {
        NSDictionary *JSONDictionary = [self JSONDictionaryFromModel:model action:action error:error];
        if (JSONDictionary == nil) return nil;
        [JSONArray addObject:JSONDictionary];
    }
    return JSONArray;
}

+ (NSArray *)JSONArrayFromModels:(NSArray *)models error:(NSError **)error {
    return [self JSONArrayFromModels:models action:nil error:error];
}

#pragma mark Lifecycle

- (id)init {
    NSAssert(NO, @"%@ must be initialized with a model class", self.class);
    return nil;
}

- (id)initWithModelClass:(Class)modelClass action:(NSString *)action {
    NSParameterAssert(modelClass != nil);
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MTLRouteJSONSerializing)]);
    
    self = [super init];
    if(self) {
        _action = action;
        _modelClass = modelClass;
        _JSONKeyPathsByPropertyKey = [[APIRouter sharedInstance] JSONKeyPathsByPropertyKey:[self class]][action][@"parameters"];
        [self validateProptyKeys];
        _valueTransformersByPropertyKey = [self.class valueTransformersForModelClass:modelClass];
        _JSONAdaptersByModelClass = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

#pragma mark - Accessors

- (void)setDepth:(NSString *)depth {
    if(_depth.length < depth.length) {
        _JSONKeyPathsByPropertyKey = _JSONKeyPathsByPropertyKey[depth];
    }
    _depth = depth;
}

- (void)setRouteClass:(Class)routeClass {
    _routeClass = routeClass;
    _JSONKeyPathsByPropertyKey = [[APIRouter sharedInstance] JSONKeyPathsByPropertyKey:[self routeClass]][self.action][@"parameters"];
    if(_depth) {
        _JSONKeyPathsByPropertyKey = _JSONKeyPathsByPropertyKey[_depth];
    }
    _valueTransformersByPropertyKey = [self.class valueTransformersForModelClass:self.modelClass];
}

#pragma marm - Serialization

- (NSSet *)serializablePropertyKeys:(NSSet *)propertyKeys forModel:(id<MTLJSONSerializing>)model {
    NSDictionary *parameters = [[APIRouter sharedInstance] JSONKeyPathsByPropertyKey:[model class]][self.action][@"parameters"];
    if(parameters.count) {
        NSSet *set = [NSSet setWithArray:parameters.allKeys];
        return set;
    }
    return propertyKeys;
}

- (NSDictionary *)serializablePropertyKeysForClass:(Class)class {
    NSDictionary *parameters = [[APIRouter sharedInstance] JSONKeyPathsByPropertyKey:class][self.action][@"parameters"];
    if(self.depth.length) {
        parameters = parameters[self.depth];
    }
    return parameters;
}

+ (NSDictionary *)valueTransformersForModelClass:(Class)modelClass {
    NSParameterAssert(modelClass != nil);
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MTLRouteJSONSerializing)]);
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for (NSString *key in [modelClass propertyKeys]) {
        SEL selector = MTLSelectorWithKeyPattern(key, "JSONTransformer");
        if ([modelClass respondsToSelector:selector]) {
            IMP imp = [modelClass methodForSelector:selector];
            NSValueTransformer * (*function)(id, SEL) = (__typeof__(function))imp;
            NSValueTransformer *transformer = function(modelClass, selector);
            
            if (transformer != nil) result[key] = transformer;
            
            continue;
        }
        
        if ([modelClass respondsToSelector:@selector(JSONTransformerForKey:)]) {
            NSValueTransformer *transformer = [modelClass JSONTransformerForKey:key];
            
            if (transformer != nil) result[key] = transformer;
            
            continue;
        }
        
        objc_property_t property = class_getProperty(modelClass, key.UTF8String);
        
        if (property == NULL) continue;
        
        mtl_propertyAttributes *attributes = mtl_copyPropertyAttributes(property);
        @onExit {
            free(attributes);
        };
        
        NSValueTransformer *transformer = nil;
        
        if (*(attributes->type) == *(@encode(id))) {
            Class propertyClass = attributes->objectClass;
            
            if (propertyClass != nil) {
                transformer = [self transformerForModelPropertiesOfClass:propertyClass];
            }
            
            if (transformer == nil) transformer = [NSValueTransformer mtl_validatingTransformerForClass:NSObject.class];
        } else {
            transformer = [self transformerForModelPropertiesOfObjCType:attributes->type] ?: [NSValueTransformer mtl_validatingTransformerForClass:NSValue.class];
        }
        
        if (transformer != nil) result[key] = transformer;
    }
    
    return result;
}

- (MTLAPIAdapter *)JSONAdapterForModelClass:(Class)modelClass action:(NSString *)action error:(NSError **)error {
    NSParameterAssert(modelClass != nil);
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MTLJSONSerializing)]);
    @synchronized(self) {
        MTLAPIAdapter *result = [self.JSONAdaptersByModelClass objectForKey:modelClass];
        if(!result) {
            result = [[[self class] alloc] initWithModelClass:modelClass action:action];
            if(result) {
                [self.JSONAdaptersByModelClass setObject:result forKey:modelClass];
            }
        }
        return result;
    }
}

+ (NSValueTransformer *)transformerForModelPropertiesOfClass:(Class)modelClass {
    NSParameterAssert(modelClass != nil);
    
    SEL selector = MTLSelectorWithKeyPattern(NSStringFromClass(modelClass), "JSONTransformer");
    if (![self respondsToSelector:selector]) return nil;
    
    IMP imp = [self methodForSelector:selector];
    NSValueTransformer * (*function)(id, SEL) = (__typeof__(function))imp;
    NSValueTransformer *result = function(self, selector);
    
    return result;
}

+ (NSValueTransformer *)transformerForModelPropertiesOfObjCType:(const char *)objCType {
    NSParameterAssert(objCType != NULL);
    if (strcmp(objCType, @encode(BOOL)) == 0) {
        return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
    }
    return nil;
}

#pragma mark - Setup

#pragma mark - Validation

- (void)validateProptyKeys {
    NSSet *propertyKeys = [self.modelClass propertyKeys];
    for (NSString *mappedPropertyKey in _JSONKeyPathsByPropertyKey) {
        if (![propertyKeys containsObject:mappedPropertyKey]) {
            NSAssert(NO, @"%@ is not a property of %@.", mappedPropertyKey, self.modelClass);
        }
        id value = _JSONKeyPathsByPropertyKey[mappedPropertyKey];
        if ([value isKindOfClass:NSDictionary.class]) {
            for (NSString *keyPath in value) {
                if ([keyPath isKindOfClass:NSString.class]) continue;
                NSAssert(NO, @"%@ must either map to a JSON key path or a JSON array of key paths, got: %@.", mappedPropertyKey, value);
            }
        } else if (![value isKindOfClass:NSString.class]) {
            NSAssert(NO, @"%@ must either map to a JSON key path or a JSON array of key paths, got: %@.",mappedPropertyKey, value);
        }
    }
}

@end

@implementation MTLAPIAdapter (ValueTransformers)

+ (NSValueTransformer<MTLTransformerErrorHandling> *)dictionaryTransformerWithModelClass:(Class)modelClass {
    NSParameterAssert([modelClass isSubclassOfClass:MTLModel.class]);
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MTLJSONSerializing)]);
    
    return [MTLValueTransformer
            transformerUsingForwardBlock:^ id (id JSONDictionary, BOOL *success, NSError **error) {
                if (JSONDictionary == nil) return nil;
                
                if (![JSONDictionary isKindOfClass:NSDictionary.class]) {
                    if (error != NULL) {
                        NSDictionary *userInfo = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert JSON dictionary to model object", @""),
                                                   NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSDictionary, got: %@", @""), JSONDictionary],
                                                   MTLTransformerErrorHandlingInputValueErrorKey : JSONDictionary
                                                   };
                        
                        *error = [NSError errorWithDomain:MTLTransformerErrorHandlingErrorDomain code:MTLTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
                    }
                    *success = NO;
                    return nil;
                }
                
                id model = [self modelOfClass:modelClass fromJSONDictionary:JSONDictionary error:error];
                if (model == nil) {
                    *success = NO;
                }
                
                return model;
            }
            reverseBlock:^ NSDictionary * (id model, BOOL *success, NSError **error) {
                if (model == nil) return nil;
                
                if (![model isKindOfClass:MTLModel.class] || ![model conformsToProtocol:@protocol(MTLJSONSerializing)]) {
                    if (error != NULL) {
                        NSDictionary *userInfo = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert model object to JSON dictionary", @""),
                                                   NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected a MTLModel object conforming to <MTLJSONSerializing>, got: %@.", @""), model],
                                                   MTLTransformerErrorHandlingInputValueErrorKey : model
                                                   };
                        
                        *error = [NSError errorWithDomain:MTLTransformerErrorHandlingErrorDomain code:MTLTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
                    }
                    *success = NO;
                    return nil;
                }
                
                NSDictionary *result = [self JSONDictionaryFromModel:model action:nil error:error];
                if (result == nil) {
                    *success = NO;
                }
                
                return result;
            }];
}

+ (NSValueTransformer<MTLTransformerErrorHandling> *)arrayTransformerWithModelClass:(Class)modelClass {
    id<MTLTransformerErrorHandling> dictionaryTransformer = [self dictionaryTransformerWithModelClass:modelClass];
    
    return [MTLValueTransformer
            transformerUsingForwardBlock:^ id (NSArray *dictionaries, BOOL *success, NSError **error) {
                if (dictionaries == nil) return nil;
                
                if (![dictionaries isKindOfClass:NSArray.class]) {
                    if (error != NULL) {
                        NSDictionary *userInfo = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert JSON array to model array", @""),
                                                   NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSArray, got: %@.", @""), dictionaries],
                                                   MTLTransformerErrorHandlingInputValueErrorKey : dictionaries
                                                   };
                        
                        *error = [NSError errorWithDomain:MTLTransformerErrorHandlingErrorDomain code:MTLTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
                    }
                    *success = NO;
                    return nil;
                }
                
                NSMutableArray *models = [NSMutableArray arrayWithCapacity:dictionaries.count];
                for (id JSONDictionary in dictionaries) {
                    if (JSONDictionary == NSNull.null) {
                        [models addObject:NSNull.null];
                        continue;
                    }
                    
                    if (![JSONDictionary isKindOfClass:NSDictionary.class]) {
                        if (error != NULL) {
                            NSDictionary *userInfo = @{
                                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert JSON array to model array", @""),
                                                       NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSDictionary or an NSNull, got: %@.", @""), JSONDictionary],
                                                       MTLTransformerErrorHandlingInputValueErrorKey : JSONDictionary
                                                       };
                            
                            *error = [NSError errorWithDomain:MTLTransformerErrorHandlingErrorDomain code:MTLTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
                        }
                        *success = NO;
                        return nil;
                    }
                    
                    id model = [dictionaryTransformer transformedValue:JSONDictionary success:success error:error];
                    
                    if (*success == NO) return nil;
                    
                    if (model == nil) continue;
                    
                    [models addObject:model];
                }
                
                return models;
            }
            reverseBlock:^ id (NSArray *models, BOOL *success, NSError **error) {
                if (models == nil) return nil;
                
                if (![models isKindOfClass:NSArray.class]) {
                    if (error != NULL) {
                        NSDictionary *userInfo = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert model array to JSON array", @""),
                                                   NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSArray, got: %@.", @""), models],
                                                   MTLTransformerErrorHandlingInputValueErrorKey : models
                                                   };
                        
                        *error = [NSError errorWithDomain:MTLTransformerErrorHandlingErrorDomain code:MTLTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
                    }
                    *success = NO;
                    return nil;
                }
                
                NSMutableArray *dictionaries = [NSMutableArray arrayWithCapacity:models.count];
                for (id model in models) {
                    if (model == NSNull.null) {
                        [dictionaries addObject:NSNull.null];
                        continue;
                    }
                    
                    if (![model isKindOfClass:MTLModel.class]) {
                        if (error != NULL) {
                            NSDictionary *userInfo = @{
                                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert JSON array to model array", @""),
                                                       NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected a MTLModel or an NSNull, got: %@.", @""), model],
                                                       MTLTransformerErrorHandlingInputValueErrorKey : model
                                                       };
                            
                            *error = [NSError errorWithDomain:MTLTransformerErrorHandlingErrorDomain code:MTLTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
                        }
                        *success = NO;
                        return nil;
                    }
                    
                    NSDictionary *dict = [dictionaryTransformer reverseTransformedValue:model success:success error:error];
                    
                    if (*success == NO) return nil;
                    
                    if (dict == nil) continue;
                    
                    [dictionaries addObject:dict];
                }
                
                return dictionaries;
            }];
}

+ (NSValueTransformer *)NSURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end

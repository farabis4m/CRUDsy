//
//  MTLRouteCoreDataAPIAdapter.m
//  Pods
//
//  Created by vlad gorbenko on 8/16/15.
//
//

#import "MTLRouteCoreDataAPIAdapter.h"

#import <CoreData/CoreData.h>

#import "MagicalRecord.h"

#import "MTLTransformerErrorHandling.h"

#import "APIRouter.h"

#import "CRUDEngine.h"

@interface MTLRouteCoreDataAPIAdapter ()

@end

@implementation MTLRouteCoreDataAPIAdapter

#pragma mark - Serialization

- (NSDictionary *)JSONDictionaryFromModel:(NSManagedObject<MTLRouteJSONSerializing> *)model action:(NSString *)action error:(NSError **)error {
    NSDictionary *parameters = [[APIRouter sharedInstance] requestJSONKeyPathsByPropertyKey:self.routeClass ?: self.modelClass action:action][@"parameters"];
    if(self.depth.length) {
        parameters = [parameters valueForKeyPath:self.depth];
    }
    NSEntityDescription *entitiy = [model entity];
    NSDictionary *properties = [entitiy propertiesByName];
    
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    BOOL (^deserializeAttribute)(NSString *, NSAttributeDescription *) = ^(NSString * key, NSAttributeDescription *attributeDescription) {
        id value = [model valueForKey:key];
        
        NSValueTransformer *transformer = self.valueTransformersByPropertyKey[parameters[key]];
        if ([transformer.class allowsReverseTransformation])
        {
            if ([transformer respondsToSelector:@selector(transformedValue:success:error:)]) {
                id<MTLTransformerErrorHandling> errorHandlingTransformer = (id)transformer;
                
                BOOL success = YES;
                value = [errorHandlingTransformer reverseTransformedValue:value success:&success error:error];
                
                if (!success) return NO;
            } else if (transformer != nil) {
                value = [transformer reverseTransformedValue:value];
            }
        }
        
        json[parameters[key]] = value;
        
        return YES;
    };
    
    BOOL (^deserializeRelationship)(NSString *key, NSRelationshipDescription *) = ^(NSString *key, NSRelationshipDescription *relationshipDescription) {
        NSArray *paths = [self.depth componentsSeparatedByString:@"."];
        if(!paths) {
            paths = @[];
        }
        paths = [paths arrayByAddingObject:relationshipDescription.name];
        self.depth = [paths componentsJoinedByString:@"."];
        
        if ([relationshipDescription isToMany]) {
            id<NSFastEnumeration> values = [model valueForKey:key];
            NSMutableArray *jsonItems = [NSMutableArray array];
            for(id value in values) {
                id jsonModel = [MTLRouteCoreDataAPIAdapter JSONDictionaryFromModel:value routeClass:self.routeClass ?: self.modelClass action:action depath:self.depth error:error];
                [jsonItems addObject:jsonModel];
            }
            if([parameters[key][@"flat"] boolValue]) {
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:parameters[key]];
                [dictionary removeObjectForKey:@"key"];
                [dictionary removeObjectForKey:@"flat"];
                jsonItems = [jsonItems valueForKeyPath:dictionary[dictionary.allKeys.firstObject]];
            }
            json[parameters[key][@"key"]] = jsonItems;
        } else {
            id value = [model valueForKey:key];
            id jsonModel = [MTLRouteCoreDataAPIAdapter JSONDictionaryFromModel:value routeClass:self.routeClass action:action depath:self.depth error:error];
            json[parameters[key]] = jsonModel;
        }
        
        paths = [self.depth componentsSeparatedByString:@"."];
        if(paths.count > 1) {
            paths = [paths subarrayWithRange:NSMakeRange(0, paths.count - 1)];
        } else {
            paths = nil;
        }
        self.depth = paths.count ? [paths componentsJoinedByString:@"."] : nil;
        
        return YES;
    };
    
    for(NSString *key in parameters.allKeys) {
        if(properties[key]) {
            NSPropertyDescription *propertyDescription = properties[key];
            NSString *propertyClassName = NSStringFromClass(propertyDescription.class);
            if ([propertyClassName isEqual:@"NSAttributeDescription"]) {
                deserializeAttribute(key, (id)propertyDescription);
            } else if([propertyClassName isEqual:@"NSRelationshipDescription"]){
                deserializeRelationship(key, (id)propertyDescription);
            }
        }
    }
    
    return json;
}


#pragma mark - Deserialization

- (id)modelFromJSONDictionary:(NSDictionary *)JSONDictionary action:(NSString *)action error:(NSError *__autoreleasing *)error {
    NSManagedObjectContext *context = [[[CRUDEngine sharedInstance] contextManager] contextForModelClass:self.modelClass action:self.action];
    NSEntityDescription *entity = [self.modelClass MR_entityDescriptionInContext:context];
    NSAssert(entity != nil, @"%@ returned a nil +entity", self.modelClass);
    
    NSAttributeDescription *primaryAttribute = [entity MR_primaryAttributeToRelateBy];
    id value = [JSONDictionary MR_valueForAttribute:primaryAttribute];
    
    NSManagedObject *managedObject = nil;
    if (primaryAttribute != nil) {
        managedObject = [self.modelClass MR_findFirstByAttribute:[primaryAttribute name] withValue:value inContext:context];
    }
    if (managedObject == nil) {
        managedObject = [self.modelClass MR_createEntityInContext:context];
    }
    [self importData:JSONDictionary toObject:managedObject];
    return managedObject;
}

#pragma mark - Utils

- (void)importData:(id)objectData toObject:(NSManagedObject *)object {
    NSDictionary *attributes = [[object entity] attributesByName];
    [self setAttributes:attributes objectData:objectData object:object];
    
    BOOL (^setValueForKey)(NSString *, id, BOOL) = ^(NSString *key, id value, BOOL validate) {
        __autoreleasing id replaceableValue = value;
        NSError *error = nil;
        if(validate) {
            if ([object validateValue:&replaceableValue forKey:key error:&error]) {
                [object setValue:replaceableValue forKey:key];
                return YES;
            }
        } else {
            [object setValue:replaceableValue forKey:key];
            return YES;
        }
        
        return NO;
    };
    
    __weak NSManagedObject *welfManagedObject = object;
    __weak typeof(self) welf = self;
    NSDictionary *relationships = [[object entity] relationshipsByName];
    [self setRelationships:relationships forKeysWithObject:objectData withBlock:^(NSRelationshipDescription *relationshipInfo, id localObjectData) {
        NSArray *paths = [welf.depth componentsSeparatedByString:@"."];
        if(!paths) {
            paths = @[];
        }
        paths = [paths arrayByAddingObject:relationshipInfo.name];
        welf.depth = [paths componentsJoinedByString:@"."];
        
        id serializableProperties = [welf serializablePropertyKeysForClass:self.routeClass];
        
        if(serializableProperties) {
            NSManagedObject *relatedObject = nil;
            
            if ([localObjectData isKindOfClass:[NSDictionary class]]) {
                NSEntityDescription *entityDescription = [relationshipInfo destinationEntity];
                Class class = NSClassFromString([entityDescription managedObjectClassName]);
                relatedObject = [MTLRouteCoreDataAPIAdapter modelOfClass:class routeClass:self.routeClass ?: self.modelClass fromJSONDictionary:localObjectData action:welf.action depath:welf.depth error:nil];
                [welf MR_addObject:relatedObject forRelationship:relationshipInfo toObject:welfManagedObject];
            } else {
                NSError *error = nil;
                id value = localObjectData;
                @try {
                    NSValueTransformer *transformer = self.valueTransformersByPropertyKey[relationshipInfo.name];
                    if (transformer != nil) {
                        // Map NSNull -> nil for the transformer, and then back for the
                        // dictionary we're going to insert into.
                        if ([value isEqual:NSNull.null]) value = nil;
                        
                        if ([transformer respondsToSelector:@selector(transformedValue:success:error:)]) {
                            id<MTLTransformerErrorHandling> errorHandlingTransformer = (id)transformer;
                            
                            BOOL success = YES;
                            value = [errorHandlingTransformer transformedValue:value success:&success error:&error];
                            
                        } else {
                            value = [transformer transformedValue:value];
                        }
                        
                        if (value == nil) value = NSNull.null;
                        else {
                            setValueForKey(relationshipInfo.name, value, NO);
                        }
                    }
                    
                } @catch (NSException *ex) {
                    NSLog(@"%@", ex);
                }
            }
        }
        
        paths = [self.depth componentsSeparatedByString:@"."];
        if(paths.count > 1) {
            paths = [paths subarrayWithRange:NSMakeRange(0, paths.count - 1)];
        } else {
            paths = nil;
        }
        self.depth = paths.count ? [paths componentsJoinedByString:@"."] : nil;
        
    }];
}

- (void)setAttributes:(NSDictionary *)attributes objectData:(id)objectData object:(NSManagedObject *)object {
    
    BOOL (^setValueForKey)(NSString *, id) = ^(NSString *key, id value) {
        __autoreleasing id replaceableValue = value;
        NSError *error = nil;
        if ([object validateValue:&replaceableValue forKey:key error:&error]) {
            [object setValue:replaceableValue forKey:key];
            return YES;
        }
        return NO;
    };
    
    NSDictionary *serializableProperties = [self serializablePropertyKeysForClass:self.routeClass];
    NSSet *serializable = [NSSet setWithArray:serializableProperties.allKeys];
    
    for (NSString *attributeName in attributes) {
        if([serializable containsObject:attributeName]) {
            NSError *error = nil;
            //            NSAttributeDescription *attributeInfo = [attributes valueForKey:attributeName];
            NSString *lookupKey = serializableProperties[attributeName];
            //            id value = [self valueForKeyPath:lookupKey];
            id value = [objectData valueForKeyPath:lookupKey];
            @try {
                NSValueTransformer *transformer = self.valueTransformersByPropertyKey[attributeName];
                if (transformer != nil) {
                    // Map NSNull -> nil for the transformer, and then back for the
                    // dictionary we're going to insert into.
                    if ([value isEqual:NSNull.null]) value = nil;
                    
                    if ([transformer respondsToSelector:@selector(transformedValue:success:error:)]) {
                        id<MTLTransformerErrorHandling> errorHandlingTransformer = (id)transformer;
                        
                        BOOL success = YES;
                        value = [errorHandlingTransformer transformedValue:value success:&success error:&error];
                        
                    } else {
                        value = [transformer transformedValue:value];
                    }
                    
                    if (value == nil) {
                        value = NSNull.null;
                    }
                    else {
                        setValueForKey(attributeName, value);
                    }
                }
                
            } @catch (NSException *ex) {
                NSLog(@"%@", ex);
            }
        }
    }
}

- (void)setRelationships:(NSDictionary *)relationships forKeysWithObject:(id)relationshipData withBlock:(void(^)(NSRelationshipDescription *,id))setRelationshipBlock {
    for (NSString *relationshipName in relationships) {
        //        if ([self MR_importValue:relationshipData forKey:relationshipName]) {
        //            continue;
        //        }
        
        NSRelationshipDescription *relationshipInfo = [relationships valueForKey:relationshipName];
        NSString *lookupKey = [[relationshipInfo userInfo] valueForKey:kMagicalRecordImportRelationshipMapKey] ?: relationshipName;
        
        id relatedObjectData;
        
        @try {
            relatedObjectData = [relationshipData valueForKeyPath:lookupKey];
        }
        @catch (NSException *exception) {
            MRLogWarn(@"Looking up a key for relationship failed while importing: %@\n", relationshipInfo);
            MRLogWarn(@"lookupKey: %@", lookupKey);
            MRLogWarn(@"relationshipInfo.destinationEntity %@", [relationshipInfo destinationEntity]);
            MRLogWarn(@"relationshipData: %@", relationshipData);
            MRLogWarn(@"Exception:\n%@: %@", [exception name], [exception reason]);
        }
        @finally {
            if (relatedObjectData == nil || [relatedObjectData isEqual:[NSNull null]])
            {
                continue;
            }
        }
        
        SEL shouldImportSelector = NSSelectorFromString([NSString stringWithFormat:@"shouldImport%@:", [relationshipName MR_capitalizedFirstCharacterString]]);
        BOOL implementsShouldImport = (BOOL)[self respondsToSelector:shouldImportSelector];
        void (^establishRelationship)(NSRelationshipDescription *, id) = ^(NSRelationshipDescription *blockInfo, id blockData)
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if (!(implementsShouldImport && !(BOOL)[self performSelector:shouldImportSelector withObject:relatedObjectData]))
            {
                setRelationshipBlock(blockInfo, blockData);
            }
#pragma clang diagnostic pop
        };
        
        if ([relationshipInfo isToMany] && [relatedObjectData isKindOfClass:[NSArray class]])
        {
            for (id singleRelatedObjectData in relatedObjectData)
            {
                establishRelationship(relationshipInfo, singleRelatedObjectData);
            }
        }
        else
        {
            establishRelationship(relationshipInfo, relatedObjectData);
        }
    }
}

- (NSManagedObject *) MR_findObjectForRelationship:(NSRelationshipDescription *)relationshipInfo withData:(id)singleRelatedObjectData forObject:(NSManagedObject *)object {
    NSEntityDescription *destinationEntity = [relationshipInfo destinationEntity];
    NSManagedObject *objectForRelationship = nil;
    
    id relatedValue;
    
    // if its a primitive class, than handle singleRelatedObjectData as the key for relationship
    if ([singleRelatedObjectData isKindOfClass:[NSString class]] ||
        [singleRelatedObjectData isKindOfClass:[NSNumber class]])
    {
        relatedValue = singleRelatedObjectData;
    }
    else if ([singleRelatedObjectData isKindOfClass:[NSDictionary class]])
    {
        relatedValue = [singleRelatedObjectData MR_relatedValueForRelationship:relationshipInfo];
    }
    else
    {
        relatedValue = singleRelatedObjectData;
    }
    
    if (relatedValue)
    {
        NSManagedObjectContext *context = [object managedObjectContext];
        Class managedObjectClass = NSClassFromString([destinationEntity managedObjectClassName]);
        NSString *primaryKey = [relationshipInfo MR_primaryKey];
        objectForRelationship = [managedObjectClass MR_findFirstByAttribute:primaryKey
                                                                  withValue:relatedValue
                                                                  inContext:context];
    }
    
    return objectForRelationship;
}

- (void) MR_addObject:(NSManagedObject *)relatedObject forRelationship:(NSRelationshipDescription *)relationshipInfo toObject:(NSManagedObject *)object {
    NSAssert2(relatedObject != nil, @"Cannot add nil to %@ for attribute %@", NSStringFromClass([self class]), [relationshipInfo name]);
    NSAssert2([[relatedObject entity] isKindOfEntity:[relationshipInfo destinationEntity]], @"related object entity %@ not same as destination entity %@", [relatedObject entity], [relationshipInfo destinationEntity]);
    
    //add related object to set
    NSString *addRelationMessageFormat = @"set%@:";
    id relationshipSource = object;
    if ([relationshipInfo isToMany])
    {
        addRelationMessageFormat = @"add%@Object:";
        if ([relationshipInfo respondsToSelector:@selector(isOrdered)] && [relationshipInfo isOrdered])
        {
            //Need to get the ordered set
            //            NSString *selectorName = [[relationshipInfo name] stringByAppendingString:@"Set"];
            NSString *selectorName = [relationshipInfo name];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            relationshipSource = [object performSelector:NSSelectorFromString(selectorName)];
#pragma clang diagnostic pop
            addRelationMessageFormat = @"addObject:";
        }
    }
    
    NSString *addRelatedObjectToSetMessage = [NSString stringWithFormat:addRelationMessageFormat, MR_attributeNameFromString([relationshipInfo name])];
    
    SEL selector = NSSelectorFromString(addRelatedObjectToSetMessage);
    
    @try
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [relationshipSource performSelector:selector withObject:relatedObject];
#pragma clang diagnostic pop
    }
    @catch (NSException *exception)
    {
        MRLogError(@"Adding object for relationship failed: %@\n", relationshipInfo);
        MRLogError(@"relatedObject.entity %@", [relatedObject entity]);
        MRLogError(@"relationshipInfo.destinationEntity %@", [relationshipInfo destinationEntity]);
        MRLogError(@"Add Relationship Selector: %@", addRelatedObjectToSetMessage);
        MRLogError(@"perform selector error: %@", exception);
    }
}


@end

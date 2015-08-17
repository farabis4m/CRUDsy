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

@implementation MTLRouteCoreDataAPIAdapter

#pragma mark - Serialization

- (NSDictionary *)JSONDictionaryFromModel:(id<MTLRouteJSONSerializing>)model action:(NSString *)action error:(NSError **)error {
    
}

#pragma mark - Deserialization

- (id)modelFromJSONDictionary:(NSDictionary *)JSONDictionary action:(NSString *)action error:(NSError *__autoreleasing *)error {
    
    NSManagedObjectContext *context = nil;//managedObject.managedObjectContext;
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
    
    BOOL (^setValueForKey)(NSString *, id) = ^(NSString *key, id value) {
        __autoreleasing id replaceableValue = value;
        if ([managedObject validateValue:&replaceableValue forKey:key error:error]) {
            [managedObject setValue:replaceableValue forKey:key];
            return YES;
        }
        return NO;
    };
    
    [self importData:JSONDictionary toObject:managedObject];
    
//    NSDictionary *managedObjectProperties = entity.propertiesByName;
//    
//    
//    NSObject<MTLModel> *model = [[self.modelClass alloc] init];
//    
//    // Pre-emptively consider this object processed, so that we don't get into
//    // any cycles when processing its relationships.
//    CFDictionaryAddValue(processedObjects, (__bridge void *)managedObject, (__bridge void *)model);
//    
//    for (NSString *propertyKey in [self.modelClass propertyKeys]) {
//        NSString *managedObjectKey = self.managedObjectKeysByPropertyKey[propertyKey];
//        if (managedObjectKey == nil) continue;
//        
//        BOOL (^deserializeAttribute)(NSAttributeDescription *) = ^(NSAttributeDescription *attributeDescription) {
//            id value = performInContext(context, ^{
//                return [managedObject valueForKey:managedObjectKey];
//            });
//            
//            NSValueTransformer *transformer = self.valueTransformersByPropertyKey[propertyKey];
//            if ([transformer respondsToSelector:@selector(transformedValue:success:error:)]) {
//                id<MTLTransformerErrorHandling> errorHandlingTransformer = (id)transformer;
//                
//                BOOL success = YES;
//                value = [errorHandlingTransformer transformedValue:value success:&success error:error];
//                
//                if (!success) return NO;
//            } else if (transformer != nil) {
//                value = [transformer transformedValue:value];
//            }
//            
//            return setValueForKey(propertyKey, value);
//        };
//        
//        BOOL (^deserializeRelationship)(NSRelationshipDescription *) = ^(NSRelationshipDescription *relationshipDescription) {
//            Class nestedClass = self.relationshipModelClassesByPropertyKey[propertyKey];
//            if (nestedClass == nil) {
//                [NSException raise:NSInvalidArgumentException format:@"No class specified for decoding relationship at key \"%@\" in managed object %@", managedObjectKey, managedObject];
//            }
//            
//            if ([relationshipDescription isToMany]) {
//                id models = performInContext(context, ^ id {
//                    id relationshipCollection = [managedObject valueForKey:managedObjectKey];
//                    NSMutableArray *models = [NSMutableArray arrayWithCapacity:[relationshipCollection count]];
//                    
//                    for (NSManagedObject *nestedObject in relationshipCollection) {
//                        id<MTLManagedObjectSerializing> model = [self.class modelOfClass:nestedClass fromManagedObject:nestedObject processedObjects:processedObjects error:error];
//                        if (model == nil) return nil;
//                        
//                        [models addObject:model];
//                    }
//                    
//                    return models;
//                });
//                
//                if (models == nil) return NO;
//                if (![relationshipDescription isOrdered]) models = [NSSet setWithArray:models];
//                
//                return setValueForKey(propertyKey, models);
//            } else {
//                NSManagedObject *nestedObject = performInContext(context, ^{
//                    return [managedObject valueForKey:managedObjectKey];
//                });
//                
//                if (nestedObject == nil) return YES;
//                
//                id<MTLManagedObjectSerializing> model = [self.class modelOfClass:nestedClass fromManagedObject:nestedObject processedObjects:processedObjects error:error];
//                if (model == nil) return NO;
//                
//                return setValueForKey(propertyKey, model);
//            }
//        };
//        
//        BOOL (^deserializeProperty)(NSPropertyDescription *) = ^(NSPropertyDescription *propertyDescription) {
//            if (propertyDescription == nil) {
//                if (error != NULL) {
//                    NSString *failureReason = [NSString stringWithFormat:NSLocalizedString(@"No property by name \"%@\" exists on the entity.", @""), managedObjectKey];
//                    
//                    NSDictionary *userInfo = @{
//                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Could not deserialize managed object", @""),
//                                               NSLocalizedFailureReasonErrorKey: failureReason,
//                                               };
//                    
//                    *error = [NSError errorWithDomain:MTLManagedObjectAdapterErrorDomain code:MTLManagedObjectAdapterErrorInvalidManagedObjectKey userInfo:userInfo];
//                }
//                
//                return NO;
//            }
//            
//            // Jump through some hoops to avoid referencing classes directly.
//            NSString *propertyClassName = NSStringFromClass(propertyDescription.class);
//            if ([propertyClassName isEqual:@"NSAttributeDescription"]) {
//                return deserializeAttribute((id)propertyDescription);
//            } else if ([propertyClassName isEqual:@"NSRelationshipDescription"]) {
//                return deserializeRelationship((id)propertyDescription);
//            } else {
//                if (error != NULL) {
//                    NSString *failureReason = [NSString stringWithFormat:NSLocalizedString(@"Property descriptions of class %@ are unsupported.", @""), propertyClassName];
//                    
//                    NSDictionary *userInfo = @{
//                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Could not deserialize managed object", @""),
//                                               NSLocalizedFailureReasonErrorKey: failureReason,
//                                               };
//                    
//                    *error = [NSError errorWithDomain:MTLManagedObjectAdapterErrorDomain code:MTLManagedObjectAdapterErrorUnsupportedManagedObjectPropertyType userInfo:userInfo];
//                }
//                
//                return NO;
//            }
//        };
//        
//        if (!deserializeProperty(managedObjectProperties[managedObjectKey])) return nil;
//    }
    
    return managedObject;
}

#pragma mark - Utils

- (void)importData:(id)objectData toObject:(NSManagedObject *)object {
    NSDictionary *attributes = [[object entity] attributesByName];
    [self setAttributes:attributes objectData:objectData];
    
    __weak NSManagedObject *welfManagedObject = object;
    __weak typeof(self) welf = self;
    NSDictionary *relationships = [[object entity] relationshipsByName];
    [self setRelationships:relationships forKeysWithObject:objectData withBlock:^(NSRelationshipDescription *relationshipInfo, id localObjectData) {
        NSManagedObject *relatedObject = [welf MR_findObjectForRelationship:relationshipInfo withData:localObjectData forObject:welfManagedObject];
        if (relatedObject == nil) {
            NSEntityDescription *entityDescription = [relationshipInfo destinationEntity];
            relatedObject = [entityDescription MR_createInstanceInContext:[welfManagedObject managedObjectContext]];
        }
        [relatedObject MR_importValuesForKeysWithObject:localObjectData];
        
        if ((localObjectData) && (![localObjectData isKindOfClass:[NSDictionary class]])) {
            NSString * relatedByAttribute = [[relationshipInfo userInfo] objectForKey:kMagicalRecordImportRelationshipLinkedByKey] ?: MR_primaryKeyNameFromString([[relationshipInfo destinationEntity] name]);
            if (relatedByAttribute) {
                [relatedObject setValue:localObjectData forKey:relatedByAttribute];
            }
        }
        [welf MR_addObject:relatedObject forRelationship:relationshipInfo toObject:welfManagedObject];
    }];
}

- (void)setAttributes:(NSDictionary *)attributes objectData:(id)objectData {
    
    BOOL (^setValueForKey)(NSString *, id) = ^(NSString *key, id value) {
        __autoreleasing id replaceableValue = value;
        NSError *error = nil;
        if ([objectData validateValue:&replaceableValue forKey:key error:&error]) {
            [objectData setValue:replaceableValue forKey:key];
            return YES;
        }
        return NO;
    };
    
    NSSet *allAttributes = [NSSet setWithArray:attributes.allKeys];
    NSSet *serializableProperties = [self serializablePropertyKeys:allAttributes forModel:objectData];
    
    
    
    for (NSString *attributeName in attributes) {
        if([serializableProperties containsObject:attributeName]) {
            NSError *error = nil;
            NSAttributeDescription *attributeInfo = [attributes valueForKey:attributeName];
            NSString *lookupKey = [[self class] JSONKeyPathsByPropertyKeyWithAction:self.action][attributeName] ?: attributeName;
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
                    
                    if (value == nil) value = NSNull.null;
                    else {
                        setValueForKey(attributeName, value);
                    }
                }

            } @catch (NSException *ex) {
                NSLog(@"%@", ex);
//                NSLog(@"*** Caught exception %@ parsing JSON key path \"%@\" from: %@", ex, JSONKeyPaths, JSONDictionary);
                
//                // Fail fast in Debug builds.
//#if DEBUG
//                @throw ex;
//#else
//                if (error != NULL) {
//                    NSDictionary *userInfo = @{
//                                               NSLocalizedDescriptionKey: ex.description,
//                                               NSLocalizedFailureReasonErrorKey: ex.reason,
//                                               MTLJSONAdapterThrownExceptionErrorKey: ex
//                                               };
//                    
//                    *error = [NSError errorWithDomain:MTLJSONAdapterErrorDomain code:MTLJSONAdapterErrorExceptionThrown userInfo:userInfo];
//                }
//                
//                return nil;
//#endif
            }
            
//            NSString *lookupKeyPath = lookupKey;//[objectData MR_lookupKeyForAttribute:attributeInfo];
//            if (lookupKeyPath) {
//                id value = [attributeInfo MR_valueForKeyPath:lookupKeyPath fromObjectData:objectData];
//                
//            }
//            else {
//                if ([[[attributeInfo userInfo] objectForKey:@"useDefaultValueWhenNotPresent"] boolValue]) {
//                    id value = [attributeInfo defaultValue];
//                    setValueForKey(attributeName, value);
//                }
//            }
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
    id relationshipSource = self;
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

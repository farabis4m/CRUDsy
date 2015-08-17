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

@interface MTLRouteCoreDataAPIAdapter ()



@end

@implementation MTLRouteCoreDataAPIAdapter

#pragma mark - Serialization

- (NSDictionary *)JSONDictionaryFromModel:(id<MTLRouteJSONSerializing>)model action:(NSString *)action error:(NSError **)error {
    
}

#pragma mark - Deserialization

- (id)modelFromJSONDictionary:(NSDictionary *)JSONDictionary action:(NSString *)action error:(NSError *__autoreleasing *)error {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
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
        
        NSEntityDescription *entityDescription = [relationshipInfo destinationEntity];
        Class class = NSClassFromString([entityDescription managedObjectClassName]);
        NSManagedObject *relatedObject = [MTLRouteCoreDataAPIAdapter modelOfClass:class routeClass:self.routeClass ?: self.modelClass fromJSONDictionary:localObjectData action:welf.action depath:welf.depth error:nil];
        
        paths = [self.depth componentsSeparatedByString:@"."];
        if(paths.count > 1) {
            paths = [paths subarrayWithRange:NSMakeRange(0, paths.count - 1)];
        } else {
            paths = nil;
        }
        self.depth = paths.count ? [paths componentsJoinedByString:@"."] : nil;
        
        if ((localObjectData) && (![localObjectData isKindOfClass:[NSDictionary class]])) {
            NSString * relatedByAttribute = [[relationshipInfo userInfo] objectForKey:kMagicalRecordImportRelationshipLinkedByKey] ?: MR_primaryKeyNameFromString([[relationshipInfo destinationEntity] name]);
            if (relatedByAttribute) {
                [relatedObject setValue:localObjectData forKey:relatedByAttribute];
            }
        }
        [welf MR_addObject:relatedObject forRelationship:relationshipInfo toObject:welfManagedObject];
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
                    
                    if (value == nil) value = NSNull.null;
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

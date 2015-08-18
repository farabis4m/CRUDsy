//
//  APIJSONAdapter.m
//  Pods
//
//  Created by vlad gorbenko on 8/13/15.
//
//

#import "APIJSONAdapter.h"

#import "APIRouter.h"

#import "NSObject+API.h"

#import <CoreData/CoreData.h>

#import "MTLRouteAPIAdapter.h"
#import "MTLRouteCoreDataAPIAdapter.h"

@implementation APIJSONAdapter

#pragma mark -

+ (id)modelOfClass:(Class)modelClass fromJSONDictionary:(NSDictionary *)JSONDictionary action:(NSString *)action error:(NSError *__autoreleasing *)error {
    if([modelClass isSubclassOfClass:[NSManagedObject class]]) {
        return [MTLRouteCoreDataAPIAdapter modelOfClass:modelClass fromJSONDictionary:JSONDictionary action:action error:error];
    } else {
        return [MTLRouteAPIAdapter modelOfClass:modelClass fromJSONDictionary:JSONDictionary action:action error:error];
    }
}

+ (NSArray *)modelsOfClass:(Class)modelClass fromJSONArray:(NSArray *)JSONArray action:(NSString *)action error:(NSError **)error {
    if([modelClass isSubclassOfClass:[NSManagedObject class]]) {
        return [MTLRouteCoreDataAPIAdapter modelsOfClass:modelClass fromJSONArray:JSONArray error:error];
    } else {
        return [MTLRouteAPIAdapter modelsOfClass:modelClass fromJSONArray:JSONArray error:error];
    }
}

+ (NSDictionary *)JSONDictionaryFromModel:(id<MTLRouteJSONSerializing>)model action:(NSString *)action error:(NSError **)error {
    if([model isKindOfClass:[NSManagedObject class]]) {
        return [MTLRouteCoreDataAPIAdapter JSONDictionaryFromModel:model action:action error:error];
    } else {
        return [MTLRouteAPIAdapter JSONDictionaryFromModel:model action:action error:error];
    }
}

@end

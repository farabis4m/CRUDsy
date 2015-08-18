//
//  APIJSONAdapter.h
//  Pods
//
//  Created by vlad gorbenko on 8/13/15.
//
//

#import <Foundation/Foundation.h>

#import "MTLRouteAPIAdapter.h"

@interface APIJSONAdapter : NSObject

+ (id)modelOfClass:(Class)modelClass fromJSONDictionary:(NSDictionary *)JSONDictionary action:(NSString *)action error:(NSError *__autoreleasing *)error;
+ (NSArray *)modelsOfClass:(Class)modelClass fromJSONArray:(NSArray *)JSONArray action:(NSString *)action error:(NSError **)error;

+ (NSDictionary *)JSONDictionaryFromModel:(id<MTLRouteJSONSerializing>)model action:(NSString *)action error:(NSError **)error;

@end

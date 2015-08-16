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

+ (id)modelOfClass:(Class)modelClass fromJSONDictionary:(NSDictionary *)JSONDictionary error:(NSError **)error;
+ (NSArray *)modelsOfClass:(Class)modelClass fromJSONArray:(NSArray *)JSONArray error:(NSError **)error;

+ (NSDictionary *)JSONDictionaryFromModel:(id<MTLJSONSerializing>)model error:(NSError **)error;

@end

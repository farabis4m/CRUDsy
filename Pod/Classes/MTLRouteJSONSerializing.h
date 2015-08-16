//
//  MTLRouteJSONSerializing.h
//  Pods
//
//  Created by vlad gorbenko on 8/16/15.
//
//

#import <Foundation/Foundation.h>

#import "MTLModel.h"

@protocol MTLRouteJSONSerializing <MTLModel>

@required
+ (NSDictionary *)JSONKeyPathsByPropertyKeyWithAction:(NSString *)action;

@optional
+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key;
+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary;

@end

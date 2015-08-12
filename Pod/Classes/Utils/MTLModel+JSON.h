//
//  MTLModel+JSON.h
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import <Mantle/Mantle.h>

@interface MTLModel (JSON)

+ (instancetype)modelFromJSON:(NSDictionary *)JSON error:(NSError **)error;
+ (instancetype)modelFromJSON:(NSDictionary *)JSON;

- (NSDictionary *)JSONWithError:(NSError **)error;
- (NSDictionary *)JSON;

@end

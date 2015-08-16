//
//  NSObject+JSON.h
//  Pods
//
//  Created by vlad gorbenko on 8/16/15.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (JSON)

+ (instancetype)modelFromJSON:(NSDictionary *)JSON error:(NSError **)error;
+ (instancetype)modelFromJSON:(NSDictionary *)JSON;

- (NSDictionary *)JSONWithError:(NSError **)error;
- (NSDictionary *)JSON;

@end

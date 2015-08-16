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
+ (instancetype)modelsFromJSON:(NSArray *)JSON error:(NSError **)error;
+ (instancetype)modelsFromJSON:(NSArray *)JSON;

- (NSDictionary *)JSONWithError:(NSError **)error;
- (NSDictionary *)JSON;

@end

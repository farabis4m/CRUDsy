//
//  MTLModel+JSON.m
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import "MTLModel+JSON.h"

@implementation MTLModel (JSON)

#pragma mark - Instance

+ (instancetype)modelFromJSON:(NSDictionary *)JSON error:(NSError **)error {
    return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:JSON error:error];
}

+ (instancetype)modelFromJSON:(NSDictionary *)JSON {
    NSError *error = nil;
    return [self modelFromJSON:JSON error:&error];
}

#pragma mark - JSON

- (NSDictionary *)JSONWithError:(NSError **)error {
    __weak id <MTLJSONSerializing> welf = (id <MTLJSONSerializing>)self;
    return [MTLJSONAdapter JSONDictionaryFromModel:welf error:error];
}

- (NSDictionary *)JSON {
    NSError *error = nil;
    return [self JSONWithError:&error];
}

@end

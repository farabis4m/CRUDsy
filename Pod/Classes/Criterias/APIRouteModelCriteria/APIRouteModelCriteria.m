//
//  APIRouteModelCriteria.m
//  Pods
//
//  Created by vlad gorbenko on 8/13/15.
//
//

#import "APIRouteModelCriteria.h"

#import "APIRouter.h"

#import "NSObject+JSON.h"

@implementation APIRouteModelCriteria

#pragma mark - JSON

- (NSDictionary *)JSONWithError:(NSError *__autoreleasing *)error {
    if([self.model conformsToProtocol:@protocol(MTLJSONSerializing)]) {
        NSObject *model = self.model;
        return [model JSONWithError:error];
    }
    NSLog(@"MODEL: %@ does not support MTL Serialization", self.model);
    return @{};
}

- (NSDictionary *)JSON {
    if([self.model conformsToProtocol:@protocol(MTLJSONSerializing)]) {
        NSObject *model = self.model;
        return [model JSON];
    }
    NSLog(@"MODEL: %@ does not support MTL Serialization", self.model);
    return @{};
}

@end

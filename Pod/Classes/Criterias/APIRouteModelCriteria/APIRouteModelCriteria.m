//
//  APIRouteModelCriteria.m
//  Pods
//
//  Created by vlad gorbenko on 8/13/15.
//
//

#import "APIRouteModelCriteria.h"

#import "APIRouter.h"

#import "MTLModel+JSON.h"

@implementation APIRouteModelCriteria

#pragma mark - JSON

- (NSDictionary *)JSON {
    if([self.model conformsToProtocol:@protocol(MTLJSONSerializing)]) {
        MTLModel *model = (MTLModel *)self.model;
        return [model JSON];
    }
    NSLog(@"MODEL: %@ does not support MTL Serialization", self.model);
    return @{};
}

@end

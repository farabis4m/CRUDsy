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

#import "APIJSONAdapter.h"

@implementation APIRouteModelCriteria

#pragma mark - APIRouteModelCriteria lifecycle

+ (instancetype)criteriaWithModel:(id<ModelIDProtocol>)model action:(NSString *)action {
    APIRouteModelCriteria *criteria = [super criteriaWithModel:model];
    criteria.action = action;
    return criteria;
}

#pragma mark - JSON

- (NSDictionary *)JSONWithError:(NSError *__autoreleasing *)error {
    if([self.model conformsToProtocol:@protocol(MTLRouteJSONSerializing)]) {
        NSObject<MTLRouteJSONSerializing> *model = self.model;
        return [APIJSONAdapter JSONDictionaryFromModel:model action:self.action error:error];
    }
    NSLog(@"MODEL: %@ does not support MTL Serialization", self.model);
    return @{};
}

- (NSDictionary *)JSON {
    NSError *error = nil;
    return [self JSONWithError:&error];
}

@end

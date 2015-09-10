//
//  APIRouteModelCriteria.m
//  Pods
//
//  Created by vlad gorbenko on 8/13/15.
//
//

#import "APIRouteModelCriteria.h"

#import "APIRouter.h"

#import <FluentJ/FluentJ.h>

@implementation APIRouteModelCriteria

#pragma mark - APIRouteModelCriteria lifecycle

+ (instancetype)criteriaWithModel:(id<ModelIDProtocol>)model action:(NSString *)action {
    APIRouteModelCriteria *criteria = [super criteriaWithModel:model];
    criteria.action = action;
    return criteria;
}

#pragma mark - JSON

- (NSDictionary *)JSONWithError:(NSError *__autoreleasing *)error {
    NSObject *model = (NSObject *)self.model;
    return [model exportValuesWithKeys:nil];
}

- (NSDictionary *)JSON {
    NSError *error = nil;
    return [self JSONWithError:&error];
}

@end

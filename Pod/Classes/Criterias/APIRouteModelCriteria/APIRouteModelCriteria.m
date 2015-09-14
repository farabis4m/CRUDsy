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

- (id)exportWithUserInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing *)error {
    NSObject *model = (NSObject *)self.model;
    NSMutableDictionary *mutableUserInfo = [NSMutableDictionary dictionary];
    [mutableUserInfo addEntriesFromDictionary:userInfo];
    [mutableUserInfo addEntriesFromDictionary:self.userInfo];
    [mutableUserInfo addEntriesFromDictionary:@{@"type" : @"request"}];
    if(self.action) {
        [mutableUserInfo addEntriesFromDictionary:@{@"action" : self.action}];
    }
    return [model exportWithUserInfo:mutableUserInfo error:error];
}

@end

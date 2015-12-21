//
//  APICriteria.m
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import "APICriteria.h"

#import <FluentJ/FluentJ.h>

NSString *const APIQueryCriteriaType = @"APIQueryCriteriaType";
NSString *const APIBodyCriteriaType = @"APIBodyCriteriaType";
NSString *const APIPathCriteriaType = @"APIPathCriteriaType";

@implementation APICriteria

#pragma mark - MTL Serialization

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{};
}

#pragma mark - Lifecycle

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    return [self initWithUserInfo:userInfo type:APIBodyCriteriaType];
}

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo type:(NSString *)type {
    self = [super init];
    if(self) {
        self.userInfo = userInfo;
        self.type = type;
    }
    return self;
}

#pragma mark - Export

- (id)exportWithUserInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing  _Nullable *)error {
    if(self.userInfo.count) {
        return self.userInfo;
    }
    return [super exportWithUserInfo:userInfo error:error];
}

@end
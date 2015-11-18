//
//  APICriteria.m
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import "APICriteria.h"

#import <FluentJ/FluentJ.h>

@implementation APICriteria

#pragma mark - MTL Serialization

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{};
}

#pragma mark - Lifecycle

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    self = [super init];
    if(self) {
        self.userInfo = userInfo;
    }
    return self;
}

#pragma mark - Export

- (id)exportWithUserInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing  _Nullable *)error {
    return self.userInfo;
}

@end
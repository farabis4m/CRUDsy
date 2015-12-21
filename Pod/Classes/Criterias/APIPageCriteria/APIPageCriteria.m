//
//  APIPageCriteria.m
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import "APIPageCriteria.h"

#import <FluentJ/FluentJ.h>

@implementation APIPageCriteria

#pragma mark - APIPageCriteria lifecycle

+ (instancetype)criteriaWithOffset:(id)offset length:(NSNumber *)legnth {
    return [[self alloc] initWithOffset:offset length:legnth];
}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.type = APIQueryCriteriaType;
    }
    return self;
}

- (instancetype)initWithOffset:(id)offset length:(NSNumber *)legnth {
    self = [super init];
    if(self) {
        self.type = APIQueryCriteriaType;
        self.offset = offset;
        self.length = legnth;
    }
    return self;
}

#pragma mark - Serialization

+ (NSDictionary *)keysForKeyPaths:(NSDictionary *)userInfo {
    return @{@"offset" : @"offset",
             @"length" : @"length"};
}

@end

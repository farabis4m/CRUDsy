//
//  APIPageCriteria.m
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import "APIPageCriteria.h"

@implementation APIPageCriteria

#pragma mark - APIPageCriteria lifecycle

+ (instancetype)criteriaWithOffset:(NSInteger)offset length:(NSInteger)legnth {
    return [[self alloc] initWithOffset:offset length:legnth];
}

- (instancetype)initWithOffset:(NSInteger)offset length:(NSInteger)legnth {
    self = [super init];
    if(self) {
        self.offset = offset;
        self.length = legnth;
    }
    return self;
}

#pragma mark - MTL Serialization

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"offset" : @"offset",
             @"length" : @"length"};
}

@end

//
//  APIResponse.m
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import "APIResponse.h"

@implementation APIResponse

#pragma mark - Lifecycle

+ (instancetype)responseWithData:(id)data error:(NSError *)error {
    return [[self alloc] initWithData:data error:error];
}

- (instancetype)initWithData:(id)data error:(NSError *)error {
    self = [super init];
    if(self) {
        self.data = data;
        self.error = error;
    }
    return self;
}

#pragma mark - Modifiers

- (void)setOffset:(id)offset {
    _offset = offset;
    _hasNext = offset != nil;
}

@end

//
//  APIUser.m
//  CRUDsy
//
//  Created by vlad gorbenko on 8/12/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import "APIUser.h"

#import "APIRouter.h"

@implementation APIUser

@synthesize id = _id;

#pragma mark - MTL Serialization

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"id" : @"id",
             @"firstname" : @"firstname",
             @"lastname" : @"lastname",
             @"age" : @"age"};
}

#pragma mark - APIUser lifecycle

+ (void)load {
    [super load];
    [[APIRouter sharedInstance] registerClass:[self class]];
}

#pragma mark - Utils

- (NSString *)fullname {
    return [NSString stringWithFormat:@"%@ %@", self.firstname, self.lastname];
}

@end

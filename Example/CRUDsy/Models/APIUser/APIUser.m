//
//  APIUser.m
//  CRUDsy
//
//  Created by vlad gorbenko on 8/12/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import "APIUser.h"

@implementation APIUser

@synthesize identifier = _identifier;

#pragma mark - JSON Serialization

+ (NSDictionary *)keysForKeyPaths:(NSDictionary *)userInfo {
    return @{@"login" : @"login",
             @"password" : @"passwrod",
             @"id" : @"id",
             @"firstname" : @"firstname",
             @"lastname" : @"lastname",
             @"age" : @"age"};
}

#pragma mark - APIUser lifecycle

#pragma mark - Utils

- (NSString *)fullname {
    return [NSString stringWithFormat:@"%@ %@", self.firstname, self.lastname];
}

@end

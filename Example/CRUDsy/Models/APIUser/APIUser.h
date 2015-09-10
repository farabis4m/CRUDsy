//
//  APIUser.h
//  CRUDsy
//
//  Created by vlad gorbenko on 8/12/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ModelIDProtocol.h"

#import <FluentJ/FluentJ.h>

@interface APIUser : NSObject <ModelIDProtocol>

@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSString *firstname;
@property (nonatomic, strong) NSString *lastname;
@property (nonatomic, assign) NSInteger age;

- (NSString *)fullname;

@end

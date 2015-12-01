//
//  APICriteria.h
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import <Foundation/Foundation.h>

extern NSString *const APIQueryCriteriaType;
extern NSString *const APIBodyCriteriaType;
extern NSString *const APIPathCriteriaType;

@interface APICriteria : NSObject

@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSString *type;

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo;
- (instancetype)initWithUserInfo:(NSDictionary *)userInfo type:(NSString *)type;

@end
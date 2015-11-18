//
//  NSObject+APIPredefinedActions.m
//  Pods
//
//  Created by vlad gorbenko on 11/18/15.
//
//

#import "NSObject+APIPredefinedActions.h"

#import "APIRouteKeys.h"

#import "NSObject+API.h"

#import "APIRouteModelCriteria.h"

@implementation NSObject (APIPredefinedActions)

#pragma mark - APICreateKey

- (NSOperation *)createWithCompletionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start {
    APIRouteModelCriteria *criteria = [APIRouteModelCriteria criteriaWithModel:self action:APICreateKey];
    return [self action:APICreateKey criterias:@[criteria] completionBlock:completionBlock start:start];
}

- (NSOperation *)createWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self createWithCompletionBlock:completionBlock start:YES];
}

+ (NSOperation *)createWithAttributes:(NSDictionary *)attributes completionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start {
    return [self action:APICreateKey attributes:attributes criterias:nil completionBlock:completionBlock start:start];
}

+ (NSOperation *)createWithAttributes:(NSDictionary *)attributes completionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self createWithAttributes:attributes completionBlock:completionBlock start:YES];
}

#pragma mark - APIIndexKey

+ (NSOperation *)listWithCriterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start {
    return [self action:APIIndexKey attributes:nil criterias:criterias completionBlock:completionBlock start:start];
}

+ (NSOperation *)listWithCriterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self listWithCriterias:criterias completionBlock:completionBlock start:YES];
}

+ (NSOperation *)listWithCompletionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start {
    return [self listWithCriterias:nil completionBlock:completionBlock start:start];
}

+ (NSOperation *)listWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self listWithCompletionBlock:completionBlock start:YES];
}

#pragma mark - APIShowKey

- (NSOperation *)showWithCriterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start {
    return [self action:APIShowKey criterias:criterias completionBlock:completionBlock start:start];
}

- (NSOperation *)showWithCriterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self showWithCriterias:criterias completionBlock:completionBlock start:YES];
}

- (NSOperation *)showWithCompletionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start {
    return [self showWithCriterias:nil completionBlock:completionBlock start:start];
}

- (NSOperation *)showWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self showWithCompletionBlock:completionBlock start:YES];
}

#pragma mark - APIUpdateKey

- (NSOperation *)updateWithCompletionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start {
    return [self action:APIUpdateKey criterias:nil completionBlock:completionBlock start:start];
}

- (NSOperation *)updateWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self updateWithCompletionBlock:completionBlock start:YES];
}

#pragma mark - APIPatchKey

- (NSOperation *)patchWithCompletionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start {
    return [self action:APIPatchKey criterias:nil completionBlock:completionBlock start:start];
}

- (NSOperation *)patchWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self patchWithCompletionBlock:completionBlock start:YES];
}

#pragma mark - APIDeleteKey

- (NSOperation *)deleteWithCompletionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start {
    return [self action:APIDeleteKey criterias:nil completionBlock:completionBlock start:start];
}

- (NSOperation *)deleteWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self deleteWithCompletionBlock:completionBlock start:YES];
}

@end

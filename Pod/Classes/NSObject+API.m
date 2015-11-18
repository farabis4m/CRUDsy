//
//  NSObject+API.m
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import "NSObject+API.h"

#import "APIRouter.h"

#import "APIMethods.h"
#import "APIRouteKeys.h"

#import "APICriteria.h"
#import "APIRouteModelCriteria.h"

#import "NSObject+Model.h"

#import "APICRUDProxy.h"

#import <FluentJ/FluentJ.h>

NSString *const APICriteriasKey = @"criterias";
NSString *const APIAttributesKey = @"attributes";
NSString *const APIStartKey = @"start";

@interface NSObject () <ModelIDProtocol>

@end

@implementation NSObject (API)

#pragma mark - MTL Serialization

+ (NSDictionary *)keysForKeyPaths:(NSDictionary *)userInfo {
    // TODO: use method parameters as userInfo dictionary.
    if([userInfo[APITypeKey] isEqualToString:APIResponseKey]) {
        NSDictionary *keys = [[APIRouter sharedInstance] responseParametersJSONKeyPathsByPropertyKey:[self class] action:userInfo[@"action"]];
        if(!keys[@"identifier"]) {
            NSMutableDictionary *mutableKeys = [NSMutableDictionary dictionaryWithDictionary:keys];
            // TODO: handle to customize it
            NSArray *ids = @[@"id", @"identifier", @"Id"];
            [mutableKeys setObject:ids forKey:@"identifier"];
            keys = mutableKeys;
        }
        return keys;
    } else if([userInfo[APITypeKey] isEqualToString:APIRequestKey]) {
        return [[APIRouter sharedInstance] requestParametersJSONKeyPathsByPropertyKey:[self class] action:userInfo[APIActionKey]];
    }
    return nil;
}

#pragma mark - API

- (NSOperation *)action:(NSString *)action parameters:(id)parameters completionBlock:(APIResponseCompletionBlock)completionBlock {
    return [[self class] action:action parameters:parameters model:self completionBlock:completionBlock];
}

+ (NSOperation *)action:(NSString *)action parameters:(id)parameters completionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self action:action parameters:parameters model:nil completionBlock:completionBlock];
}

- (NSOperation *)action:(NSString *)action criterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start {
    return [[self class] requestWithAction:action routeSource:[self class] criterias:criterias start:start model:self completionBlock:completionBlock];
}

- (NSOperation *)action:(NSString *)action criterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self action:action criterias:criterias completionBlock:completionBlock start:FALSE];
}

+ (NSOperation *)action:(NSString *)action attributes:(NSDictionary *)attributes criterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start {
    APICriteria *criteria = [[APICriteria alloc] initWithUserInfo:attributes];
    return [self requestWithAction:action routeSource:self criterias:[criterias arrayByAddingObject:criteria] start:start model:nil completionBlock:completionBlock];
}

+ (NSOperation *)action:(NSString *)action attributes:(NSDictionary *)attributes criterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self action:action attributes:attributes criterias:criterias completionBlock:completionBlock start:FALSE];
}

+ (NSOperation *)action:(NSString *)action parameters:(id)parameters model:(id)model completionBlock:(APIResponseCompletionBlock)completionBlock {
    NSArray *criterias = nil;
    NSDictionary *attributes = nil;
    BOOL start = FALSE;
    if([parameters isKindOfClass:[NSArray class]]) {
        criterias = [[self class] findSpecificClassItemInArray:parameters subitemClass:[NSArray class]];
        attributes = [[self class] findSpecificClassItemInArray:parameters subitemClass:[NSDictionary class]];
        NSNumber *startNumber = [[self class] findSpecificClassItemInArray:parameters subitemClass:[NSNumber class]];
        start = startNumber ? [startNumber boolValue] : FALSE;
    } else if([parameters isKindOfClass:[NSDictionary class]]) {
        criterias = [parameters objectForKey:APICreateKey];
        attributes = [parameters objectForKey:APIAttributesKey];
        NSNumber *startNumber = [parameters objectForKey:APIStartKey];
        start = startNumber ? [startNumber boolValue] : FALSE;
    }
    return [self requestWithAction:action routeSource:self criterias:criterias start:start model:model completionBlock:completionBlock];
}

#pragma mark - Utils

+ (NSOperation *)requestWithAction:(NSString *)action criterias:(NSArray *)criterias start:(BOOL)start completionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self requestWithAction:action routeSource:self criterias:criterias start:start completionBlock:completionBlock];
}

+ (NSOperation *)requestWithAction:(NSString *)action routeSource:(Class)routeSource criterias:(NSArray *)criterias start:(BOOL)start completionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self requestWithAction:action routeSource:[self class] criterias:criterias start:start model:nil completionBlock:completionBlock];
}

- (NSOperation *)requestWithAction:(NSString *)action routeSource:(Class)routeSource criterias:(NSArray *)criterias start:(BOOL)start completionBlock:(APIResponseCompletionBlock)completionBlock {
    return [[self class] requestWithAction:action routeSource:[self class] criterias:criterias start:start model:self completionBlock:completionBlock];
}

+ (NSOperation *)requestWithAction:(NSString *)action routeSource:(Class)routeSource criterias:(NSArray *)criterias start:(BOOL)start model:(id)model completionBlock:(APIResponseCompletionBlock)completionBlock {
    NSMutableDictionary *parametrs = [NSMutableDictionary dictionary];
    NSPredicate *queryPredicate = [NSPredicate predicateWithFormat:@"class == %@", [APIModelCriteria modelIdentifier]];
    NSArray *queryCriterias = [criterias filteredArrayUsingPredicate:queryPredicate];
    for(APICriteria *criteria in criterias) {
        [parametrs addEntriesFromDictionary:[criteria exportWithUserInfo:nil error:nil]];
    }
    return [APICRUDProxy operationForAction:action modelClass:self routeSource:routeSource parameters:parametrs model:model criterias:queryCriterias start:start completionBlock:completionBlock];
}

+ (id)findSpecificClassItemInArray:(NSArray *)array subitemClass:(Class)subitemClass {
    id classItem = nil;
    for(id item in array) {
        if([item isKindOfClass:subitemClass]) {
            classItem = item;
            break;
        }
    }
    return classItem;
}


@end

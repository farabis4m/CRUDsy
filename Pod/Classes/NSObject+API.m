//
//  NSObject+API.m
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import "NSObject+API.h"

#import "CRUDEngine.h"

#import "APIRouter.h"

#import "APIMethods.h"
#import "APIRouteKeys.h"

#import "APICriteria.h"
#import "APIRouteModelCriteria.h"

#import "NSString+Pluralize.h"

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
    if([userInfo[@"type"] isEqualToString:@"response"]) {
        NSDictionary *keys = [[APIRouter sharedInstance] responseParametersJSONKeyPathsByPropertyKey:[self class] action:userInfo[@"action"]];
        if(!keys[@"identifier"]) {
            NSMutableDictionary *mutableKeys = [NSMutableDictionary dictionaryWithDictionary:keys];
            // TODO: handle to customize it
            NSArray *ids = @[@"id", @"identifier", @"Id"];
            [mutableKeys setObject:ids forKey:@"identifier"];
            keys = mutableKeys;
        }
        return keys;
    } else if([userInfo[@"type"] isEqualToString:@"request"]) {
        return [[APIRouter sharedInstance] requestParametersJSONKeyPathsByPropertyKey:[self class] action:userInfo[@"action"]];
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
    return [[self class] requestWithKey:action routeSource:[self class] criterias:criterias start:start model:self completionBlock:completionBlock];
}

- (NSOperation *)action:(NSString *)action criterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self action:action criterias:criterias completionBlock:completionBlock start:FALSE];
}

+ (NSOperation *)action:(NSString *)action attributes:(NSDictionary *)attributes criterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start {
    APICriteria *criteria = [[APICriteria alloc] initWithUserInfo:attributes];
    return [self requestWithKey:action routeSource:self criterias:[criterias arrayByAddingObject:criteria] start:start model:nil completionBlock:completionBlock];
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
    return [self requestWithKey:action routeSource:self criterias:criterias start:start model:model completionBlock:completionBlock];
}

#pragma mark - Utils

+ (NSString *)modelString {
    return NSStringFromClass([self class]);
}

+ (NSOperation *)requestWithKey:(NSString *)key criterias:(NSArray *)criterias start:(BOOL)start completionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self requestWithKey:key routeSource:self criterias:criterias start:start completionBlock:completionBlock];
}

+ (NSOperation *)requestWithKey:(NSString *)key routeSource:(Class)routeSource criterias:(NSArray *)criterias start:(BOOL)start completionBlock:(APIResponseCompletionBlock)completionBlock {
    return [self requestWithKey:key routeSource:[self class] criterias:criterias start:start model:nil completionBlock:completionBlock];
}

- (NSOperation *)requestWithKey:(NSString *)key routeSource:(Class)routeSource criterias:(NSArray *)criterias start:(BOOL)start completionBlock:(APIResponseCompletionBlock)completionBlock {
    return [[self class] requestWithKey:key routeSource:[self class] criterias:criterias start:start model:self completionBlock:completionBlock];
}

+ (NSOperation *)requestWithKey:(NSString *)key routeSource:(Class)routeSource criterias:(NSArray *)criterias start:(BOOL)start model:(id)model completionBlock:(APIResponseCompletionBlock)completionBlock {
    NSMutableDictionary *parametrs = [NSMutableDictionary dictionary];
    for(APICriteria *criteria in criterias) {
        [parametrs addEntriesFromDictionary:[criteria exportWithUserInfo:nil error:nil]];
    }
    return [self callWithAction:key routeSource:self parameters:parametrs model:model start:start completionBlock:completionBlock];
}

+ (NSOperation *)callWithAction:(NSString *)action routeSource:(Class)routeSource parameters:(id)parameters model:(id)model start:(BOOL)start completionBlock:(APIResponseCompletionBlock)completionBlock {
    CRUDEngine *engine = [CRUDEngine sharedInstance];
    APIRouter *router = [APIRouter sharedInstance];
    [router registerClass:[self class]];
    [router registerClass:routeSource];
    NSString *modelString = [routeSource modelString];
    NSString *URLString = [[APIRouter sharedInstance] buildURLForClass:[[self class] modelString] action:action];
    NSString *route = [router routeForClassString:modelString action:action];
    NSString *method = [router methodForClassString:modelString action:action];

    NSURL *URL = [NSURL URLWithString:URLString];
    APIResponseCompletionBlock completion = ^(APIResponse *response) {
        if(!response.error) {
            NSError *parseError = nil;
            id result = model;
            [self parseJson:response.data class:[self class] action:action error:&parseError model:&result];
            response.data = result;
            response.error = parseError;
        }
        completionBlock(response);
    };
    NSString *requestType = [[APIRouter sharedInstance] requestTypeForClassString:modelString action:action];
    id operaiton = [engine HTTPRequestOperationURL:URL HTTPMethod:method URLString:route type:requestType parameters:parameters completionBlock:completion];
    if(start) {
        [[CRUDEngine sharedInstance] startOperation:operaiton];
    }
    return operaiton;
}

+ (void)parseJson:(id)json class:(Class)class action:(NSString *)action error:(NSError **)error model:(id *)model {
    id context = [[[CRUDEngine sharedInstance] contextManager] contextForModelClass:self action:action];
    NSDictionary *userInfo = @{APIActionKey : action,
                               APITypeKey : APIResponseKey};
    if(model) {
        [*model updateWithValue:json context:context userInfo:userInfo error:error];
        return;
    }
    APIImportType definedImportType = [[APIRouter sharedInstance] importTypeWithClass:class action:action];
    APIImportType importType = APIImportTypeForAction(action);
    if(definedImportType != APIImportTypeUndefined) {
        importType = definedImportType;
    }
    BOOL shouldParse = [[APIRouter sharedInstance] shouldParseWithClassString:[self modelString] action:action];
    id result = nil;
    if(shouldParse) {
        switch (importType) {
            case APIImportTypeArray: {
                BOOL isDictionary = [json isKindOfClass:[NSDictionary class]];
                if(isDictionary) {
                    NSArray *keys = [json allKeys];
                    json = json[keys.lastObject];
                }
                result = [class importValue:json context:context userInfo:userInfo error:error];
            }
            case APIImportTypeDictionary: result = [class importValue:json context:context userInfo:userInfo error:error];
            case APIImportTypeNone: result = json;
            case APIImportTypeUndefined: result = nil;
        }
    }
    if(model) {
        *model = result;
    }
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

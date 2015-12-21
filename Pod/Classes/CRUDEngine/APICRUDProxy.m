//
//  APICRUDProxy.m
//  Pods
//
//  Created by vlad gorbenko on 11/18/15.
//
//

#import "APICRUDProxy.h"

#import "CRUDEngine.h"
#import "NSObject+Model.h"

#import "APIModelCriteria.h"

#import <FluentJ/FluentJ.h>
#import "APIRouteKeys.h"

#import <AFNetworking/AFHTTPRequestOperation.h>

@implementation APICRUDProxy

+ (NSOperation *)operationForAction:(NSString *)action modelClass:(Class)modelClass routeSource:(Class)routeSource parameters:(id)parameters model:(id)model criterias:(NSArray *)criterias start:(BOOL)start completionBlock:(APIResponseCompletionBlock)completionBlock {
    CRUDEngine *engine = [CRUDEngine sharedInstance];
    APIRouter *router = [APIRouter sharedInstance];
    [router registerClass:modelClass];
    modelClass = [[APIRouter sharedInstance] modelClassForClass:modelClass action:action];
    [router registerClass:modelClass];
    [router registerClass:routeSource];
    NSString *modelString = [routeSource modelIdentifier];
    NSString *URLString = [[APIRouter sharedInstance] buildURLForClass:[modelClass modelIdentifier] action:action];
    NSString *route = [self routeForModelClass:routeSource action:action criterias:criterias];
    NSString *method = [router methodForClassString:modelString action:action];

    NSPredicate *queryFilter = [NSPredicate predicateWithFormat:@"self.type = %@", APIQueryCriteriaType];
    NSArray *queryCriterias = [criterias filteredArrayUsingPredicate:queryFilter];
    NSMutableDictionary *queryParamters = [NSMutableDictionary dictionary];
    for(APICriteria *criteria in queryCriterias) {
        NSError *error = nil;
        [queryParamters addEntriesFromDictionary:[criteria exportWithUserInfo:@{APIActionKey : action} error:&error]];
        if(error) {
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
        }
    }
    NSMutableString *queryParametersString = [NSMutableString string];
    NSArray *keys = queryParamters.allKeys;
    for(id key in keys) {
        [queryParametersString appendFormat:@"%@=%@", key, queryParamters[key]];
        if(key != [keys lastObject]) {
            [queryParametersString appendString:@"&"];
        }
    }
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSString *requestType = [[APIRouter sharedInstance] requestTypeForClassString:modelString action:action];
    id operation = [engine HTTPRequestOperationURL:URL HTTPMethod:method URLString:route type:requestType parameters:parameters success:^(NSOperation *operation, id responseObject) {
        AFHTTPRequestOperation *requestOperation = (AFHTTPRequestOperation *)operation;
        id response = [engine.parser parse:responseObject response:requestOperation.response class:modelClass routeClass:routeSource action:action model:model];
        completionBlock(response);
    } failure:^(NSOperation *operation, NSError *error) {
        AFHTTPRequestOperation *requestOperation = (AFHTTPRequestOperation *)operation;
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[error userInfo]];
        userInfo[CRUDResponseDataKey] = requestOperation.responseObject;
        NSDictionary *notificationUserInfo = @{CRUDErrorDataKey : error, CRUDOperationDataKey : operation};
        [[NSNotificationCenter defaultCenter] postNotificationName:CRUDOperationFailureOperationNotification object:notificationUserInfo];
        error = [NSError errorWithDomain:@"com.CRUDsy.response" code:requestOperation.response.statusCode userInfo:userInfo];
        APIResponse *response = [APIResponse responseWithData:requestOperation.responseObject error:error];
        completionBlock(response);
    }];
    if(start) {
        [[CRUDEngine sharedInstance] startOperation:operation];
    }
    return operation;
}

+ (NSString *)routeForModelClass:(Class)class action:(NSString *)action criterias:(NSArray *)criterias {
    NSString *route = [[APIRouter sharedInstance] routeForClassString:[class modelIdentifier] action:action];
    for(APIModelCriteria *criteria in criterias) {
        if([criteria respondsToSelector:@selector(templateKey)] && criteria.templateKey) {
            NSRange range = [route rangeOfString:criteria.templateKey];
            if(criteria.templateKey && range.location != NSNotFound) {
                id model = criteria.model;
                id value = [model valueForKeyPath:criteria.templateKey];
                NSString *valueString = [NSString stringWithFormat:@"%@", value];
                route = [route stringByReplacingCharactersInRange:range withString:valueString];
            }
        }
    }
    return route;
}

@end

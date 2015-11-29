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

@implementation APICRUDProxy

+ (NSOperation *)operationForAction:(NSString *)action modelClass:(Class)modelClass routeSource:(Class)routeSource parameters:(id)parameters model:(id)model criterias:(NSArray *)criterias start:(BOOL)start completionBlock:(APIResponseCompletionBlock)completionBlock {
    CRUDEngine *engine = [CRUDEngine sharedInstance];
    APIRouter *router = [APIRouter sharedInstance];
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
        [queryParamters addEntriesFromDictionary:[criteria exportWithUserInfo:@{APIActionKey : action} error:nil]];
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
    id operaiton = [engine HTTPRequestOperationURL:URL HTTPMethod:method URLString:route type:requestType parameters:parameters completionBlock:^(APIResponse *response) {
        if(!response.error) {
            NSError *error = nil;
            response.data = [engine.parser parse:response.data class:modelClass routeClass:routeSource action:action error:&error model:model];
        }
        completionBlock(response);
    }];
    if(start) {
        [[CRUDEngine sharedInstance] startOperation:operaiton];
    }
    return operaiton;
}

+ (NSString *)routeForModelClass:(Class)class action:(NSString *)action criterias:(NSArray *)criterias {
    NSString *route = [[APIRouter sharedInstance] routeForClassString:[class modelIdentifier] action:action];
    for(APIModelCriteria *criteria in criterias) {
        if(criteria.templateKey && [route containsString:criteria.templateKey]) {
            id model = criteria.model;
            id value = [model valueForKeyPath:criteria.templateKey];
            NSString *valueString = [NSString stringWithFormat:@"%@", value];
            route = [route stringByReplacingOccurrencesOfString:criteria.templateKey withString:valueString];
        }
    }
    return route;
}

@end

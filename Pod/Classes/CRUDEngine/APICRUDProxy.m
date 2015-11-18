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

@implementation APICRUDProxy

+ (NSOperation *)operationForAction:(NSString *)action modelClass:(Class)modelClass routeSource:(Class)routeSource parameters:(id)parameters model:(id)model start:(BOOL)start completionBlock:(APIResponseCompletionBlock)completionBlock {
    CRUDEngine *engine = [CRUDEngine sharedInstance];
    APIRouter *router = [APIRouter sharedInstance];
    [router registerClass:[self class]];
    [router registerClass:routeSource];
    NSString *modelString = [routeSource modelIdentifier];
    NSString *URLString = [[APIRouter sharedInstance] buildURLForClass:[[self class] modelIdentifier] action:action];
    NSString *route = [router routeForClassString:modelString action:action];
    NSString *method = [router methodForClassString:modelString action:action];
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSString *requestType = [[APIRouter sharedInstance] requestTypeForClassString:modelString action:action];
    id operaiton = [engine HTTPRequestOperationURL:URL HTTPMethod:method URLString:route type:requestType parameters:parameters completionBlock:^(APIResponse *response) {
        if(response.error) {
            NSError *error = nil;
            response.data = [engine.parser parse:response.data class:routeSource action:action error:&error model:model];
        }
        completionBlock(response);
    }];
    if(start) {
        [[CRUDEngine sharedInstance] startOperation:operaiton];
    }
    return operaiton;
}

@end

//
//  APICRUDProxy.h
//  Pods
//
//  Created by vlad gorbenko on 11/18/15.
//
//

#import <Foundation/Foundation.h>

#import "APICompletionBlock.h"

@interface APICRUDProxy : NSObject

+ (NSOperation *)operationForAction:(NSString *)action modelClass:(Class)modelClass routeSource:(Class)routeSource parameters:(id)parameters model:(id)model criterias:(NSArray *)criterias start:(BOOL)start completionBlock:(APIResponseCompletionBlock)completionBlock;

@end

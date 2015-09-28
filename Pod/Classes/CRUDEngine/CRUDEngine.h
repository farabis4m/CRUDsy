//
//  CRUDEngine.h
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import <Foundation/Foundation.h>

#import "APIMethods.h"
#import "APICompletionBlock.h"

#import "APIRouter.h"

#import "APIContextProtocol.h"

@class AFHTTPRequestSerializer;
@class AFHTTPResponseSerializer;

@interface CRUDEngine : NSObject

@property (nonatomic, strong) id<APIContextProtocol> contextManager;

@property (nonatomic, strong) APIRouter *APIRouter;

@property (nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;
@property (nonatomic, strong) AFHTTPResponseSerializer *responseSerializer;

@property (nonatomic, strong) NSURL *baseURL;

+ (instancetype)sharedInstance;

- (id)HTTPRequestOperationURL:(NSURL *)URL HTTPMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters completionBlock:(APIResponseCompletionBlock)completionBlock;

// TOOD: test method
- (id)HTTPRequestOperationURL:(NSURL *)URL HTTPMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters multipart:(BOOL)multipart completionBlock:(APIResponseCompletionBlock)completionBlock;

@end

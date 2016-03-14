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
#import "APIParserProtocol.h"

@class AFHTTPRequestSerializer;
@class AFHTTPResponseSerializer;

extern NSString *const CRUDOperationFailureOperationNotification;
extern NSString *const CRUDResponseDataKey;
extern NSString *const CRUDOperationDataKey;
extern NSString *const CRUDErrorDataKey;

@interface CRUDEngine : NSObject

@property (nonatomic, strong) id<APIContextProtocol> contextManager;
@property (nonatomic, strong) id<APIParserProtocol> parser;

@property (nonatomic, strong) APIRouter *APIRouter;

@property (nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;
@property (nonatomic, strong) AFHTTPResponseSerializer *responseSerializer;

@property (nonatomic, strong) NSURL *baseURL;

+ (instancetype)sharedInstance;

- (void)cancelAllRequests;
- (void)startOperation:(NSOperation *)operation;

- (id)HTTPRequestOperationURL:(NSURL *)URL HTTPMethod:(NSString *)method URLString:(NSString *)URLString type:(NSString *)type parameters:(id)parameters success:(void (^)(NSOperation *operation, id responseObject))success failure:(void (^)(NSOperation *operation, NSError *error))failure;

- (id)HTTPMutipartRequestOperationURL:(NSURL *)URL HTTPMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSOperation *operation, id responseObject))success failure:(void (^)(NSOperation *operation, NSError *error))failure;

- (NSArray *)batch:(NSArray *)operations progress:(void (^)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations))progress completion:(void (^)(NSArray *operations))completion;

@end

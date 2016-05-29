//
//  CRUDEngine.m
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import "CRUDEngine.h"

#import <AFNetworking/AFNetworking.h>

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

#import "CRUDParser.h"

#import "CRUDAttachement.h"

NSString *const CRUDOperationFailureOperationNotification = @"CRUDOperationFailureOperationNotification";
NSString *const CRUDResponseDataKey = @"CRUDResponseDataKey";
NSString *const CRUDOperationDataKey = @"CRUDOperationDataKey";
NSString *const CRUDErrorDataKey = @"CRUDErrorDataKey";

@interface CRUDEngine ()

@end

@implementation CRUDEngine

#pragma mark - Signleton pattern

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

#pragma mark - CRUDEngine lifecycle

- (instancetype)init {
    self = [super init];
    if(self) {
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        self.operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
        self.parser = [[CRUDParser alloc] init];
    }
    return self;
}

#pragma mark - Modifiers

- (void)setBaseURL:(NSURL *)baseURL {
    _baseURL = baseURL;
    self.operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
}

- (void)setRequestSerializer:(AFHTTPRequestSerializer *)requestSerializer {
    self.operationManager.requestSerializer = requestSerializer;
}

- (void)setResponseSerializer:(AFHTTPResponseSerializer *)responseSerializer {
    self.operationManager.responseSerializer = responseSerializer;
}

#pragma mark - Accessors

- (AFHTTPRequestSerializer *)requestSerializer {
    return self.operationManager.requestSerializer;
}

- (AFHTTPResponseSerializer *)responseSerializer {
    return self.operationManager.responseSerializer;
}

- (NSOperationQueue *)operationQueue {
    return self.operationManager.operationQueue;
}

#pragma mark - Management

- (void)cancelAllRequests {
    [self.operationManager.operationQueue cancelAllOperations];
}

#pragma mark - Utils

- (void)startOperation:(NSOperation *)operation {
    [self.operationManager.operationQueue addOperation:operation];
}

- (id)HTTPMutipartRequestOperationURL:(NSURL *)URL HTTPMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSOperation *operation, id responseObject))success failure:(void (^)(NSOperation *operation, NSError *error))failure {
    
    NSMutableArray *values = [NSMutableArray arrayWithArray:[parameters allValues]];
    [values removeObjectIdenticalTo:[NSNull null]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self isKindOfClass: %@", [CRUDAttachement class]];
    NSArray *dataObjects = [values filteredArrayUsingPredicate:predicate];
    NSMutableArray *dataKeys = [NSMutableArray array];
    for(id dataObject in dataObjects) {
        NSArray *keys = [parameters allKeysForObject:dataObject];
        [dataKeys addObjectsFromArray:keys];
    }
    
    NSMutableDictionary *allParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    NSDictionary *dataParameters = [allParameters dictionaryWithValuesForKeys:dataKeys];
    [allParameters removeObjectsForKeys:dataKeys];
    
    NSError *serializationError = nil;
    NSURL *fullURL = [URL URLByAppendingPathComponent:URLString];
    NSString *relativeURLString = [fullURL absoluteString];
    NSURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:method URLString:relativeURLString parameters:allParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for(id key in dataKeys) {
            CRUDAttachement *attachement = dataParameters[key];
            [formData appendPartWithFileData:attachement.data name:key fileName:attachement.filename mimeType:attachement.mimeType];
        }
    } error:&serializationError];
    return [self operationWithReqiest:request success:success failure:failure];
}

- (id)HTTPSimpleRequestOperationURL:(NSURL *)URL HTTPMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSOperation *operation, id responseObject))success failure:(void (^)(NSOperation *operation, NSError *error))failure {
    NSError *serializationError = nil;
    NSURL *fullURL = URL;
    if(URLString.length) {
        fullURL = [URL URLByAppendingPathComponent:URLString];
    }
    NSString *relativeURLString = [fullURL absoluteString];
    NSMutableURLRequest *request = [self.operationManager.requestSerializer requestWithMethod:method URLString:relativeURLString  parameters:parameters error:&serializationError];
    if (serializationError) {
        if(failure) {
            //            APIResponse *response = [[APIResponse alloc] init];
            //            response.error = serializationError;
            dispatch_async(self.operationManager.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
        }
        return nil;
    }
    return [self operationWithReqiest:request success:success failure:failure];
}

- (id)HTTPRequestOperationURL:(NSURL *)URL HTTPMethod:(NSString *)method URLString:(NSString *)URLString type:(NSString *)type parameters:(id)parameters success:(void (^)(NSOperation *operation, id responseObject))success failure:(void (^)(NSOperation *operation, NSError *error))failure {
    if(type == APIRequestTypeMultipartData) {
        return [self HTTPMutipartRequestOperationURL:URL HTTPMethod:method URLString:URLString parameters:parameters success:success failure:failure];
    } else if(type == APIRequestTypeURLEncoded) {
        return [self HTTPSimpleRequestOperationURL:URL HTTPMethod:method URLString:URLString parameters:parameters success:success failure:failure];
    }
    return nil;
}

- (AFHTTPRequestOperation *)operationWithReqiest:(NSURLRequest *)request success:(void (^)(NSOperation *operation, id responseObject))success failure:(void (^)(NSOperation *operation, NSError *error))failure {
    id operation = [self.operationManager HTTPRequestOperationWithRequest:request success:success failure:failure];
    return operation;
}

- (nonnull NSArray<NSOperation *> *)batch:(nonnull NSArray *)operations progress:(void (^ __nullable)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations))progress completion:(void (^ __nullable)(NSArray * __nonnull operations))completion {
    NSArray *batchedOperations = [AFURLConnectionOperation batchOfRequestOperations:operations progressBlock:progress completionBlock:completion];
    [[NSOperationQueue mainQueue] addOperations:batchedOperations waitUntilFinished:NO];
    return batchedOperations;
}


@end

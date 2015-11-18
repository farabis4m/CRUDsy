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

@interface CRUDEngine ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;

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
    }
    return self;
}

#pragma mark - Modifiers

- (void)setBaseURL:(NSURL *)baseURL {
    _baseURL = baseURL;
    self.operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
}

- (void)setRequestSerializer:(AFHTTPRequestSerializer *)requestSerializer {
    _requestSerializer = requestSerializer;
    self.operationManager.requestSerializer = requestSerializer;
}

- (void)setResponseSerializer:(AFHTTPResponseSerializer *)responseSerializer {
    _responseSerializer = responseSerializer;
    self.operationManager.responseSerializer = responseSerializer;
}

#pragma mark - Management

- (void)cancelAllRequests {
    [self.operationManager.operationQueue cancelAllOperations];
}

#pragma mark - Utils

- (void)startOperation:(NSOperation *)operation {
    [self.operationManager.operationQueue addOperation:operation];
}

- (id)HTTPMutipartRequestOperationURL:(NSURL *)URL HTTPMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters completionBlock:(APIResponseCompletionBlock)completionBlock {
    
    NSArray *values = [parameters allValues];
    NSArray *dataObjects = [values filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class == %@", [NSData class]]];
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
            [formData appendPartWithFormData:dataParameters[key] name:key];
        }
    } error:&serializationError];
    return [self operationWithReqiest:request completionBlock:completionBlock];
}

- (id)HTTPSimpleRequestOperationURL:(NSURL *)URL HTTPMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters completionBlock:(APIResponseCompletionBlock)completionBlock {
    NSError *serializationError = nil;
    NSURL *fullURL = [URL URLByAppendingPathComponent:URLString];
    NSString *relativeURLString = [fullURL absoluteString];
    NSMutableURLRequest *request = [self.operationManager.requestSerializer requestWithMethod:method URLString:relativeURLString  parameters:parameters error:&serializationError];
    if (serializationError) {
        if(completionBlock) {
            APIResponse *response = [[APIResponse alloc] init];
            response.error = serializationError;
            dispatch_async(self.operationManager.completionQueue ?: dispatch_get_main_queue(), ^{
                completionBlock(response);
            });
        }
        return nil;
    }
    return [self operationWithReqiest:request completionBlock:completionBlock];
}

- (id)HTTPRequestOperationURL:(NSURL *)URL HTTPMethod:(NSString *)method URLString:(NSString *)URLString type:(NSString *)type parameters:(id)parameters completionBlock:(APIResponseCompletionBlock)completionBlock {
    if(type == APIRequestTypeMultipartData) {
        return [self HTTPMutipartRequestOperationURL:URL HTTPMethod:method URLString:URLString parameters:parameters completionBlock:completionBlock];
    } else if(type == APIRequestTypeURLEncoded) {
        return [self HTTPSimpleRequestOperationURL:URL HTTPMethod:method URLString:URLString parameters:parameters completionBlock:completionBlock];
    }
    return nil;
}

- (AFHTTPRequestOperation *)operationWithReqiest:(NSURLRequest *)request completionBlock:(APIResponseCompletionBlock)completionBlock {
    id operation = [self.operationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id responseResult = responseObject;//[self.APIAdapter prepareForParsingResponseObject:responseObject];
        APIResponse *response = [[APIResponse alloc] init];
        response.data = responseResult;
        completionBlock(response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // TODO: fix notification
        // TODO: support for repeat operation
        NSString *responseString = nil;
        if(operation.responseData.bytes > 0) {
            responseString = [NSString stringWithUTF8String:[operation.responseData bytes]];
        }
        NSLog(@"ERROR :%@ %@", [error localizedDescription], responseString);
        NSLog(@"ERROR DESCR: %@", [NSHTTPURLResponse localizedStringForStatusCode:operation.response.statusCode]);
        APIResponse *response = [[APIResponse alloc] init];
        response.error = error;
        if(operation.response.statusCode == 401) {
            NSError *error = [NSError errorWithDomain:@"com.API" code:0 userInfo:@{NSLocalizedDescriptionKey : operation.responseObject[@"ErrorMessage"]}];
            response.error = error;
            completionBlock(response);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Unauthorized" object:nil];
        } else {
            completionBlock(response);
        }
    }];
    return operation;
}

@end

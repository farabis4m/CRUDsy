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
        
//        NSString *filepath = [[NSBundle mainBundle] pathForResource:FTAPIOperationTypesFileName ofType:@"plist"];
//        self.operationTypes = [NSDictionary dictionaryWithContentsOfFile:filepath];
        
//        self.APIAdapter = [[APIAdapter alloc] init];
    }
    return self;
}

#pragma mark - Modifiers

- (void)setBaseURL:(NSURL *)baseURL {
    _baseURL = baseURL;
    self.operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
}

#pragma mark - Utils

- (id)HTTPRequestOperationURL:(NSURL *)URL HTTPMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters completionBlock:(APIResponseCompletionBlock)completionBlock {
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
    AFHTTPRequestOperation *operation = [self.operationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id responseResult = responseObject;//[self.APIAdapter prepareForParsingResponseObject:responseObject];
        APIResponse *response = [[APIResponse alloc] init];
        response.data = responseResult;
        completionBlock(response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *responseString = nil;
        if(operation.responseData != nil) {
            responseString = [NSString stringWithUTF8String:[operation.responseData bytes]];
        }
        NSLog(@"ERROR :%@ %@", [error localizedDescription], responseString);
        NSLog(@"ERROR DESCR: %@", [NSHTTPURLResponse localizedStringForStatusCode:operation.response.statusCode]);
        APIResponse *response = [[APIResponse alloc] init];
        response.error = error;
        if(operation.response.statusCode == 404) {
            NSError *error = [NSError errorWithDomain:@"com.API" code:0 userInfo:@{NSLocalizedDescriptionKey : operation.responseObject[@"ErrorMessage"]}];
            response.error = error;
            completionBlock(response);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Unauthorized" object:nil];
        } else {
            completionBlock(response);
        }
    }];
    [self.operationManager.operationQueue addOperation:operation];
    return operation;
}

@end

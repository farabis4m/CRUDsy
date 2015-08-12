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

#import "APICriteria.h"

#import "MTLModel+JSON.h"

#import <Mantle/MTLJSONAdapter.h>

typedef NS_ENUM (NSInteger, FTAPIImportType) {
    FTAPIImportTypeArray,
    FTAPIImportTypeDictionary,
    FTAPIImportTypeNone
};

@implementation NSObject (API)

#pragma mark - Class lifecycle

+ (void)load {
    [[APIRouter sharedInstance] registerClass:[self class]];
}

#pragma mark - API

+ (void)listWithCompletionBlock:(FTAPIResponseCompletionBlock)completionBlock {
    [self listWithCriterias:nil completionBlock:completionBlock];
}

+ (void)listWithCriterias:(NSArray *)criterias completionBlock:(FTAPIResponseCompletionBlock)completionBlock {
    NSString *modelString = [self modelString];
    NSString *URLString = [[APIRouter sharedInstance] baseURLs][modelString][APIIndexKey];
    NSString *route = [[APIRouter sharedInstance] routes][modelString][APIIndexKey];
    if(!route) {
        route = modelString;
    }
    route = [route lowercaseString];
    NSString *method = [[APIRouter sharedInstance] methods][modelString][APIIndexKey];
    if(!method) {
        method = APIMethodGET;
    }
    NSMutableDictionary *parametrs = [NSMutableDictionary dictionary];
    for(APICriteria *criteria in criterias) {
        [parametrs addEntriesFromDictionary:[criteria JSON]];
    }
    [self callWithURL:URLString Method:method route:route parameters:parametrs importType:FTAPIImportTypeArray completionBlock:completionBlock];
}

- (void)showWithCompletionBlock:(FTAPIResponseCompletionBlock)completionBlock {
}

- (void)createWithCompletionBlock:(FTAPIResponseCompletionBlock)completionBlock {
}

- (void)updateWithCompletionBlock:(FTAPIResponseCompletionBlock)completionBlock {
}

- (void)deleteWithCompletionBlock:(FTAPIResponseCompletionBlock)completionBlock {
}

#pragma mark - Utils

+ (NSString *)modelString {
    NSString *classString = NSStringFromClass([self class]);
    NSInteger index = 0;
    for(NSInteger i = 0; i < [classString length]; i++) {
        unichar letter = [classString characterAtIndex:i];
        if([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:letter]) {
            index++;
        } else {
            break;
        }
    }
    return [classString substringFromIndex:index];
}

+ (void)callWithURL:(NSString *)URLString Method:(NSString *)method route:(NSString *)route parameters:(id)parameters importType:(FTAPIImportType)importType completionBlock:(FTAPIResponseCompletionBlock)completionBlock {
    CRUDEngine *engine = [CRUDEngine sharedInstance];
    
    NSURL *URL = URLString ? [NSURL URLWithString:URLString] : nil;
    [engine HTTPRequestOperationURL:URL HTTPMethod:method URLString:route parameters:parameters completionBlock:^(APIResponse *response) {
        if(!response.error) {
            NSError *parseError = nil;
            id result = [self parseJson:response.data importType:importType class:[self class] error:&parseError];
            response.data = result;
            response.error = parseError;
        }
        completionBlock(response);
    }];
}

+ (id)parseJson:(id)json importType:(FTAPIImportType)importType class:(Class)class error:(NSError **)error {
    switch (importType) {
        case FTAPIImportTypeArray: return [MTLJSONAdapter modelsOfClass:class fromJSONArray:json error:error];
        case FTAPIImportTypeDictionary: return [MTLJSONAdapter modelOfClass:class fromJSONDictionary:json error:error];
        case FTAPIImportTypeNone: return json;
    }
    return nil;
}

@end

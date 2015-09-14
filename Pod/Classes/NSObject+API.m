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
#import "APIRouteModelCriteria.h"

#import "NSString+Pluralize.h"

#import <FluentJ/FluentJ.h>

@interface NSObject () <ModelIDProtocol>

@end

@implementation NSObject (API)

#pragma mark - MTL Serialization

+ (NSDictionary *)keysForKeyPaths:(NSDictionary *)userInfo {
    // TODO: use method parameters as userInfo dictionary.
    NSDictionary *keys = [[APIRouter sharedInstance] responseParametersJSONKeyPathsByPropertyKey:[self class] action:userInfo[@"action"]];
    if(!keys[@"identifier"]) {
        NSMutableDictionary *mutableKeys = [NSMutableDictionary dictionaryWithDictionary:keys];
        // TODO: handle to customize it
        NSArray *ids = @[@"id", @"identifier", @"Id"];
        [mutableKeys setObject:ids forKey:@"identifier"];
        keys = mutableKeys;
    }
    return keys;
}

#pragma mark - API

+ (void)listWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
    [self listWithCriterias:nil completionBlock:completionBlock];
}

+ (void)listWithCriterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock {
    [self requestWithKey:APIIndexKey criterias:criterias importType:APIImportTypeArray completionBlock:completionBlock];
}

- (void)showWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
    id criteria = [APIRouteModelCriteria criteriaWithModel:self action:APIShowKey];
    [[self class] requestWithKey:APIShowKey criterias:@[criteria] importType:APIImportTypeDictionary completionBlock:completionBlock];
}

- (void)createWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
    id criteria = [APIRouteModelCriteria criteriaWithModel:self action:APICreateKey];
    [[self class] requestWithKey:APICreateKey criterias:@[criteria] importType:APIImportTypeDictionary completionBlock:completionBlock];
}

- (void)updateWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
    id criteria = [APIRouteModelCriteria criteriaWithModel:self action:APIUpdateKey];
    [[self class] requestWithKey:APIUpdateKey criterias:@[criteria] importType:APIImportTypeDictionary completionBlock:completionBlock];
}

- (void)deleteWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
    id criteria = [APIRouteModelCriteria criteriaWithModel:self action:APIDeleteKey];
    [[self class] requestWithKey:APIDeleteKey criterias:@[criteria] importType:APIImportTypeDictionary completionBlock:completionBlock];
}

#pragma mark - Utils

+ (NSString *)modelString {
    return NSStringFromClass([self class]);
}

+ (void)requestWithKey:(NSString *)key criterias:(NSArray *)criterias importType:(APIImportType)importType completionBlock:(APIResponseCompletionBlock)completionBlock {
    NSString *modelString = [self modelString];
    NSString *URLString = [[APIRouter sharedInstance] urlForClassString:modelString action:key];
    NSString *route = [[APIRouter sharedInstance] routeForClassString:modelString action:key];
    NSString *method = [[APIRouter sharedInstance] methodForClassString:modelString action:key];
    NSMutableDictionary *parametrs = [NSMutableDictionary dictionary];
    for(APICriteria *criteria in criterias) {
        [parametrs addEntriesFromDictionary:[criteria exportWithUserInfo:nil error:nil]];
    }
    [self callWithURL:URLString Method:method route:route action:key parameters:parametrs importType:importType completionBlock:completionBlock];
}

+ (void)requestWithKey:(NSString *)key method:(NSString *)method route:(NSString *)route criterias:(NSArray *)criterias importType:(APIImportType)importType completionBlock:(APIResponseCompletionBlock)completionBlock {
    NSString *URLString = [[APIRouter sharedInstance] urlForClassString:[self modelString] action:key];
    NSMutableDictionary *parametrs = [NSMutableDictionary dictionary];
    for(APICriteria *criteria in criterias) {
        [parametrs addEntriesFromDictionary:[criteria exportWithUserInfo:nil error:nil]];
    }
    [self callWithURL:URLString Method:method route:route action:key parameters:parametrs importType:importType completionBlock:completionBlock];
}

+ (void)callWithURL:(NSString *)URLString Method:(NSString *)method route:(NSString *)route action:(NSString *)action parameters:(id)parameters importType:(APIImportType)importType completionBlock:(APIResponseCompletionBlock)completionBlock {
    CRUDEngine *engine = [CRUDEngine sharedInstance];
    
    NSURL *URL = [NSURL URLWithString:URLString ?: [APIRouter sharedInstance].baseURL];
    [engine HTTPRequestOperationURL:URL HTTPMethod:method URLString:route parameters:parameters completionBlock:^(APIResponse *response) {
        if(!response.error) {
            NSError *parseError = nil;
            id result = [self parseJson:response.data importType:importType class:[self class] action:action error:&parseError];
            response.data = result;
            response.error = parseError;
        }
        completionBlock(response);
    }];
}

+ (id)parseJson:(id)json importType:(APIImportType)importType class:(Class)class action:(NSString *)action error:(NSError **)error {
    APIImportType definedImportType = [[APIRouter sharedInstance] importTypeWithClass:class action:action];
    if(definedImportType != APIImportTypeUndefined) {
        importType = definedImportType;
    }
    id context = [[[CRUDEngine sharedInstance] contextManager] contextForModelClass:self action:action];
    switch (importType) {
        case APIImportTypeArray: {
            BOOL isDictionary = [json isKindOfClass:[NSDictionary class]];
            if(isDictionary) {
                NSArray *keys = [json allKeys];
                json = json[keys.lastObject];
            }
            return [class importValue:json context:context userInfo:@{@"action" : action} error:error]
            ;
        }
            
        case APIImportTypeDictionary: return [class importValue:json context:context userInfo:@{@"action" : action} error:error];
        case APIImportTypeNone: return json;
        case APIImportTypeUndefined: return nil;
    }
    return nil;
}

@end

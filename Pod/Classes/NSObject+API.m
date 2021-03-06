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

#import "NSObject+JSON.h"

#import <Mantle/MTLJSONAdapter.h>

#import "APIJSONAdapter.h"

#import "APIRouteModelCriteria.h"

#import "NSString+Pluralize.h"

#import <Mantle/MTLModel.h>

@interface NSObject () <ModelIDProtocol, MTLJSONSerializing>

@end

@implementation NSObject (API)

#pragma mark - MTL Serialization

+ (NSDictionary *)JSONKeyPathsByPropertyKeyWithAction:(NSString *)action {
    return [[APIRouter sharedInstance] responseJSONKeyPathsByPropertyKey:[self class] action:action][@"parameters"];
}

#pragma mark - API

+ (void)listWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
    [self listWithCriterias:nil completionBlock:completionBlock];
}

+ (void)listWithCriterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock {
    NSString *route = [[[self class] modelString] pluralize];
    [self requestWithKey:APIIndexKey method:APIMethodGET route:route criterias:criterias importType:APIImportTypeArray completionBlock:completionBlock];
}

- (void)showWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
    id criteria = [APIRouteModelCriteria criteriaWithModel:self action:APIShowKey];
    NSString *route = [[[self class] modelString] pluralize];
    [[self class] requestWithKey:APIShowKey method:APIMethodGET route:route criterias:@[criteria] importType:APIImportTypeDictionary completionBlock:completionBlock];
}

- (void)createWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
    id criteria = [APIRouteModelCriteria criteriaWithModel:self action:APICreateKey];
    NSString *route = [[self class] modelString];
    [[self class] requestWithKey:APICreateKey method:APIMethodPOST route:route criterias:@[criteria] importType:APIImportTypeDictionary completionBlock:completionBlock];
}

- (void)updateWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
    id criteria = [APIRouteModelCriteria criteriaWithModel:self action:APIUpdateKey];
    NSString *route = [[self class] modelString];
    [[self class] requestWithKey:APIUpdateKey method:APIMethodPUT route:route criterias:@[criteria] importType:APIImportTypeDictionary completionBlock:completionBlock];
}

- (void)deleteWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
    id criteria = [APIRouteModelCriteria criteriaWithModel:self action:APIDeleteKey];
    NSString *route = [[self class] modelString];
    [[self class] requestWithKey:APIDeleteKey method:APIMethodDELETE route:route criterias:@[criteria] importType:APIImportTypeDictionary completionBlock:completionBlock];
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
    return [classString substringFromIndex:index - 1];
}

+ (void)requestWithKey:(NSString *)key method:(NSString *)method route:(NSString *)route criterias:(NSArray *)criterias importType:(APIImportType)importType completionBlock:(APIResponseCompletionBlock)completionBlock {
    NSString *modelString = [self modelString];
    NSString *URLString = [[APIRouter sharedInstance] baseURLs][modelString][key];
    if(!URLString) {
        URLString = [[APIRouter sharedInstance] baseURL];
    }
    NSString *finalRoute = [[APIRouter sharedInstance] routes][modelString][key];
    if(!finalRoute) {
        finalRoute = modelString;
    }
    NSString *finalMethod = [[APIRouter sharedInstance] methods][modelString][key];
    if(!finalMethod) {
        finalMethod = method;
    }
    NSMutableDictionary *parametrs = [NSMutableDictionary dictionary];
    for(APICriteria *criteria in criterias) {
        [parametrs addEntriesFromDictionary:[criteria JSON]];
    }
    [self callWithURL:URLString Method:finalMethod route:finalRoute action:key parameters:parametrs importType:importType completionBlock:completionBlock];
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
    switch (importType) {
        case APIImportTypeArray: return [APIJSONAdapter modelsOfClass:class fromJSONArray:json action:action error:error];
        case APIImportTypeDictionary: return [APIJSONAdapter modelOfClass:class fromJSONDictionary:json action:action error:error];
        case APIImportTypeNone: return json;
        case APIImportTypeUndefined: return nil;
    }
    return nil;
}

@end

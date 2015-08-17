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

#import "APIModelCriteria.h"

#import "NSString+Pluralize.h"

#import <Mantle/MTLModel.h>

@interface NSObject () <ModelIDProtocol, MTLJSONSerializing>

@end

@implementation NSObject (API)

#pragma mark - MTL Serialization

+ (NSDictionary *)JSONKeyPathsByPropertyKeyWithAction:(NSString *)action {
    return [[APIRouter sharedInstance] JSONKeyPathsByPropertyKey:[self class]][action][@"parameters"];
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
    id criteria = [APIModelCriteria criteriaWithModel:self];
    NSString *route = [[[self class] modelString] pluralize];
    [[self class] requestWithKey:APIShowKey method:APIMethodGET route:route criterias:@[criteria] importType:APIImportTypeDictionary completionBlock:completionBlock];
}

- (void)createWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
}

- (void)updateWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
}

- (void)deleteWithCompletionBlock:(APIResponseCompletionBlock)completionBlock {
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
    return [[classString substringFromIndex:index - 1] lowercaseString];
}

+ (void)requestWithKey:(NSString *)key method:(NSString *)method route:(NSString *)route criterias:(NSArray *)criterias importType:(APIImportType)importType completionBlock:(APIResponseCompletionBlock)completionBlock {
    NSString *modelString = [self modelString];
    NSString *URLString = [[APIRouter sharedInstance] baseURLs][modelString][key];
    NSString *finalRoute = [[APIRouter sharedInstance] routes][modelString][key];
    if(!finalRoute) {
        finalRoute = modelString;
    }
    finalRoute = [finalRoute lowercaseString];
    NSString *finalMethod = [[APIRouter sharedInstance] methods][modelString][key];
    if(!finalMethod) {
        finalMethod = method;
    }
    NSMutableDictionary *parametrs = [NSMutableDictionary dictionary];
    for(APICriteria *criteria in criterias) {
        [parametrs addEntriesFromDictionary:[criteria JSON]];
    }
    [self callWithURL:URLString Method:finalMethod route:finalRoute parameters:parametrs importType:importType completionBlock:completionBlock];
}

+ (void)callWithURL:(NSString *)URLString Method:(NSString *)method route:(NSString *)route parameters:(id)parameters importType:(APIImportType)importType completionBlock:(APIResponseCompletionBlock)completionBlock {
    CRUDEngine *engine = [CRUDEngine sharedInstance];
    
    NSURL *URL = [NSURL URLWithString:URLString ?: [APIRouter sharedInstance].baseURL];
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

+ (id)parseJson:(id)json importType:(APIImportType)importType class:(Class)class error:(NSError **)error {
    switch (importType) {
        case APIImportTypeArray: return [class modelsFromJSON:json error:error];
        case APIImportTypeDictionary: return [class modelFromJSON:json error:error];
        case APIImportTypeNone: return json;
    }
    return nil;
}

@end

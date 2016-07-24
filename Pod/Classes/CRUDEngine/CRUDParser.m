//
//  CRUDParser.m
//  Pods
//
//  Created by vlad gorbenko on 11/18/15.
//
//

#import "CRUDParser.h"

#import "APIImportType.h"
#import "APIRouteKeys.h"

#import "APIRouter.h"

#import "NSObject+Model.h"

#import <FluentJ/FluentJ.h>
#import <InflectorKit/NSString+InflectorKit.h>

#import "CRUDEngine.h"

@implementation CRUDParser

#pragma mark - Parsing

- (id)parse:(id)responseObject class:(Class)class routeClass:(Class)routeClass action:(NSString *)action error:(NSError **)error model:(id)model {
    id context = [[[CRUDEngine sharedInstance] contextManager] contextForModelClass:class action:action];
    NSDictionary *userInfo = @{APIActionKey : action, APITypeKey : APIResponseKey};
    APIImportType importType = [[APIRouter sharedInstance] importTypeWithClass:routeClass action:action];
    if(model && importType == APIImportTypeDictionary && ![responseObject isKindOfClass:[NSArray class]]) {
        NSString *dataKey = [[class modelIdentifier] lowercaseString];
        NSDictionary *data = (NSDictionary *)responseObject;
        NSDictionary *modelData = data[dataKey] ?: responseObject;
        [model willImportWithUserInfo:userInfo];
        [model updateWithValue:modelData context:context userInfo:userInfo error:error];
        [model didImportWithUserInfo:userInfo];
        return model;
    }
    
    id result = nil;
    switch (importType) {
        case APIImportTypeArray: {
            NSString *dataKey = [[[class modelIdentifier] lowercaseString] pluralizedString];
            BOOL isDictionary = [responseObject isKindOfClass:[NSDictionary class]];
            id data = isDictionary && responseObject[dataKey] ? responseObject[dataKey] : responseObject;
            isDictionary = [data isKindOfClass:[NSDictionary class]];
            if(isDictionary) {
                NSArray *keys = [data allKeys];
                data = data[keys.lastObject];
            }
            result = [class importValue:data context:context userInfo:userInfo error:error];
        } break;
        case APIImportTypeDictionary: {
            NSString *dataKey = [[class modelIdentifier] lowercaseString];
            NSDictionary *data = (NSDictionary *)responseObject;
            NSDictionary *modelData = data[dataKey] ?: responseObject;
            result = [class importValue:modelData context:context userInfo:userInfo error:error];
        } break;
        case APIImportTypeNone: result = responseObject; break;
        case APIImportTypeUndefined: result = nil;
    }
    BOOL shouldParse = [[APIRouter sharedInstance] shouldParseWithClassString:[class modelIdentifier] action:action];
    return shouldParse ? result : responseObject;
}

- (APIResponse *)parse:(id)responseObject response:(NSHTTPURLResponse *)response class:(Class)class routeClass:(Class)routeClass action:(NSString *)action model:(id)model {
    APIResponse *apiResponse = [[APIResponse alloc] init];
    NSError *error = nil;
    if([responseObject conformsToProtocol:@protocol(NSFastEnumeration)]) {
        apiResponse.data = [self parse:responseObject class:class routeClass:routeClass action:action error:&error model:model];
    } else {
        apiResponse.data = responseObject;
    }
    apiResponse.error = error;
    apiResponse.offset = [response allHeaderFields][@"X-ITEM-OFFSET"];
    apiResponse.totalItemsCount = [response allHeaderFields][@"X-TOTAL-ITEMS-COUNT"];
    return apiResponse;
}

@end

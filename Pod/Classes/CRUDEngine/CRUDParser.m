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

#import "CRUDEngine.h"

@implementation CRUDParser

#pragma mark - Parsing

- (id)parse:(id)responseObject class:(Class)class routeClass:(Class)routeClass action:(NSString *)action error:(NSError **)error model:(id)model {
    id context = [[[CRUDEngine sharedInstance] contextManager] contextForModelClass:class action:action];
    NSDictionary *userInfo = @{APIActionKey : action,
                               APITypeKey : APIResponseKey};
    APIImportType definedImportType = [[APIRouter sharedInstance] importTypeWithClass:routeClass action:action];
    if(model && definedImportType != APIImportTypeNone) {
        [model updateWithValue:responseObject context:context userInfo:userInfo error:error];
        return model;
    }
    
    APIImportType importType = APIImportTypeForAction(action);
    if(definedImportType != APIImportTypeUndefined) {
        importType = definedImportType;
    }
    BOOL shouldParse = [[APIRouter sharedInstance] shouldParseWithClassString:[class modelIdentifier] action:action];
    id result = nil;
    if(shouldParse) {
        switch (importType) {
            case APIImportTypeArray: {
                BOOL isDictionary = [responseObject isKindOfClass:[NSDictionary class]];
                if(isDictionary) {
                    NSArray *keys = [responseObject allKeys];
                    responseObject = responseObject[keys.lastObject];
                }
                result = [class importValue:responseObject context:context userInfo:userInfo error:error];
            } break;
            case APIImportTypeDictionary: result = [class importValue:responseObject context:context userInfo:userInfo error:error]; break;
            case APIImportTypeNone: result = responseObject; break;
            case APIImportTypeUndefined: result = nil;
        }
    }
    return result;
}

@end

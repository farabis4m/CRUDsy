//
//  APIRouter.h
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import <Foundation/Foundation.h>

#import "APIImportType.h"

#import "APIRouteKeys.h"

/**
 Class that handle pattern based URLs to custom user defined.
 Example: GET /items to POST /GETMyItems.
 Depends on realistaion of server side.
 */
@interface APIRouter : NSObject

@property (nonatomic, strong) NSString *baseURL;

+ (instancetype)sharedInstance;

- (void)registerClass:(Class)class;

- (NSString *)urlForClassString:(NSString *)classString action:(NSString *)action;
- (NSString *)routeForClassString:(NSString *)classString action:(NSString *)action;
- (NSString *)methodForClassString:(NSString *)classString action:(NSString *)action;
- (NSDictionary *)requestParametersJSONKeyPathsByPropertyKey:(Class)class action:(NSString *)action;
- (NSDictionary *)responseParametersJSONKeyPathsByPropertyKey:(Class)class action:(NSString *)action;;

- (APIImportType)importTypeWithClass:(Class)class action:(NSString *)action;

+ (void)setURL:(NSString *)url forKey:(NSString *)key model:(NSString *)model;
+ (void)setRoute:(NSString *)route forKey:(NSString *)key model:(NSString *)model;
+ (void)setMethod:(NSString *)method forKey:(NSString *)key model:(NSString *)model;

@end
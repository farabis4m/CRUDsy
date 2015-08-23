//
//  APIRouter.h
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import <Foundation/Foundation.h>

#import "APIImportType.h"

extern NSString *const APIIndexKey;
extern NSString *const APICreateKey;
extern NSString *const APIShowKey;
extern NSString *const APIUpdateKey;
extern NSString *const APIDeleteKey;

/**
 Class that handle pattern based URLs to custom user defined.
 Example: GET /items to POST /GETMyItems.
 Depends on realistaion of server side.
 */
@interface APIRouter : NSObject

@property (nonatomic, strong) NSString *baseURL;

@property (nonatomic, strong, readonly) NSDictionary *baseURLs;
@property (nonatomic, strong, readonly) NSDictionary *routes;
@property (nonatomic, strong, readonly) NSDictionary *methods;

+ (instancetype)sharedInstance;

- (void)registerClass:(Class)class;
- (NSDictionary *)parametersWithClass:(Class)class;
- (NSDictionary *)requestJSONKeyPathsByPropertyKey:(Class)class action:(NSString *)action;
- (NSDictionary *)responseJSONKeyPathsByPropertyKey:(Class)class action:(NSString *)action;;

- (APIImportType)importTypeWithClass:(Class)class action:(NSString *)action;

+ (void)setURL:(NSString *)url forKey:(NSString *)key model:(NSString *)model;
+ (void)setRoute:(NSString *)route forKey:(NSString *)key model:(NSString *)model;
+ (void)setMethod:(NSString *)method forKey:(NSString *)key model:(NSString *)model;

@end
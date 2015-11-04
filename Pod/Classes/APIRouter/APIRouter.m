//
//  APIRouter.m
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import "APIRouter.h"

#import "APIMethods.h"
#import "APIRouteKeys.h"

NSString *const APIFormatArray = @"array";
NSString *const APIFormatDictionary = @"dictionary";
NSString *const APIFormatNone = @"none";

static NSMutableDictionary *definedRoutes = nil;
static NSMutableDictionary *definedURLs = nil;
static NSMutableDictionary *definedMethods = nil;

#import "NSObject+API.h"

#import "NSString+Pluralize.h"

#import <FluentJ/FluentJ.h>

@interface APIRouter ()

@property (nonatomic, strong) NSMutableArray *registeredClasses;

@property (nonatomic, strong) NSMutableDictionary *predefinedRoutes;

@end

@implementation APIRouter

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

#pragma mark - APIRouter lifecycle

- (instancetype)init {
    self = [super init];
    if(self) {
        [self setup];
    }
    return self;
}

#pragma mark - Setup

- (void)setup {
    self.registeredClasses = [NSMutableArray array];
    self.predefinedRoutes = [NSMutableDictionary dictionary];
}

#pragma mark -

- (void)registerClass:(Class)class {
    NSString *classString = NSStringFromClass(class);
    if(![self.registeredClasses containsObject:classString]) {
        [self.registeredClasses addObject:classString];
        [self flushRoutesForClass:[class modelString]];
    }
}

+ (void)setURL:(NSString *)url forKey:(NSString *)key model:(NSString *)model {
    NSMutableDictionary *dictionary = definedURLs;
    [self setValue:url forKey:key model:model dictionary:&dictionary];
    if(!definedURLs) {
        definedURLs = dictionary;
    }
}

+ (void)setRoute:(NSString *)route forKey:(NSString *)key model:(NSString *)model {
    NSMutableDictionary *dictionary = definedRoutes;
    [self setValue:route forKey:key model:model dictionary:&dictionary];
    if(!definedRoutes) {
        definedRoutes = dictionary;
    }
}

+ (void)setMethod:(NSString *)method forKey:(NSString *)key model:(NSString *)model {
    NSMutableDictionary *dictionary = definedMethods;
    [self setValue:method forKey:key model:model dictionary:&dictionary];
    if(!definedMethods) {
        definedMethods = dictionary;
    }
}

+ (void)setValue:(NSString *)value forKey:(NSString *)key model:(NSString *)model dictionary:(NSMutableDictionary **)dictionary {
    if(!*dictionary) {
        *dictionary = [[NSMutableDictionary alloc] init];
    }
    NSMutableDictionary *modelDictionary = (*dictionary)[model];
    if(!modelDictionary) {
        modelDictionary = [[NSMutableDictionary alloc] init];
        [*dictionary setValue:modelDictionary forKey:model];
    }
    [modelDictionary setValue:value forKey:key];
}

#pragma mark - Accessors

- (APIImportType)importTypeWithClass:(Class)class action:(NSString *)action {
    static NSDictionary *bindings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bindings = @{APIFormatArray : @(APIImportTypeArray),
                     APIFormatDictionary : @(APIImportTypeDictionary),
                     APIFormatNone : @(APIImportTypeNone)};
    });
    id format = self.predefinedRoutes[[class modelString]][action][@"format"];
    if([format isKindOfClass:[NSString class]]) {
        return [bindings[format] integerValue];
    }
    return [format integerValue];
}

- (NSString *)urlForClassString:(NSString *)classString action:(NSString *)action {
    return self.predefinedRoutes[classString][action][@"url"] ?: self.baseURL;
}

- (NSString *)routeForClassString:(NSString *)classString action:(NSString *)action {
    return self.predefinedRoutes[classString][action][@"route"] ?: [classString pluralize];
}

- (NSString *)methodForClassString:(NSString *)classString action:(NSString *)action {
    NSString *method = self.predefinedRoutes[classString][action][@"method"];
    if(!method) {
        NSDictionary *actionsTable = @{APIIndexKey : APIMethodGET,
                                       APIShowKey : APIMethodGET,
                                       APIDeleteKey : APIMethodDELETE,
                                       APICreateKey : APIMethodPOST,
                                       APIUpdateKey : APIMethodPUT};
        method = actionsTable[action];
    }
    return method;
}

- (NSDictionary *)requestParametersJSONKeyPathsByPropertyKey:(Class)class action:(NSString *)action {
    return self.predefinedRoutes[[class modelString]][action][@"request"][@"parameters"] ?: [class keysForKeyPaths:@{@"action" : action}];
}

- (NSDictionary *)responseParametersJSONKeyPathsByPropertyKey:(Class)class action:(NSString *)action; {
    if(!action) {
        return nil;
    }
    return self.predefinedRoutes[[class modelString]][action][@"response"][@"parameters"];
}

- (BOOL)isMultipart:(NSString *)classString action:(NSString *)action {
    BOOL multipart = [self.predefinedRoutes[classString][action][@"multipart"] boolValue];
    return multipart;
}

- (NSString *)buildURLForClass:(NSString *)class action:(NSString *)action {
    NSString *defaultURL = [self urlForClassString:class action:action];
    NSString *finalURL = defaultURL;
    if(self.urlBuilder) {
        finalURL = [self.urlBuilder buildURLWithString:defaultURL];
    }
    return finalURL;
}

#pragma mark - Utils

- (void)flushRoutesForClass:(NSString *)classString {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:classString ofType:@"plist"];
    if(!filePath) {
        return;
    }
    NSDictionary *classRoutes = [NSDictionary dictionaryWithContentsOfFile:filePath];
    for(NSString *APIKey in classRoutes.allKeys) {
        NSDictionary *define = classRoutes[APIKey];
        NSString *method = define[@"method"];
        if(method.length) {
            [[self class] setMethod:method forKey:APIKey model:classString];
        }
        NSString *url = define[@"url"];
        if(url.length) {
            [[self class] setURL:url forKey:APIKey model:classString];
        }
        NSString *route = define[@"route"];
        if(route.length) {
            [[self class] setRoute:route forKey:APIKey model:classString];
        }
    }
    [self.predefinedRoutes setObject:classRoutes forKey:classString];
}

@end
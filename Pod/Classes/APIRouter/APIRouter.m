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
NSString *const APIFormatDictionary = @"object";
NSString *const APIFormatNone = @"none";

static NSMutableDictionary *definedRoutes = nil;
static NSMutableDictionary *definedURLs = nil;
static NSMutableDictionary *definedMethods = nil;

#import "NSObject+Model.h"

#import <FluentJ/FluentJ.h>
#import <InflectorKit/NSString+InflectorKit.h>

APIImportType APIImportTypeForAction(NSString *action) {
    return [[APIRouter APIActionImportTypes][action] integerValue];
}

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
        [self flushRoutesForClass:[class modelIdentifier]];
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
    id format = self.predefinedRoutes[[class modelIdentifier]][action][APIFormatKey];
    if([format isKindOfClass:[NSString class]]) {
        return [[APIRouter APIConfigurationImportTypes][[format lowercaseString]] integerValue];
    }
    return [format integerValue];
}

- (NSString *)urlForClassString:(NSString *)classString action:(NSString *)action {
    return self.predefinedRoutes[classString][action][APIURLKey] ?: self.baseURL;
}

- (NSString *)routeForClassString:(NSString *)classString action:(NSString *)action {
    NSString *modelIdentifier = classString;
    NSRange range = [modelIdentifier rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet] options:NSLiteralSearch];
    NSString *modelName = [modelIdentifier substringWithRange:NSMakeRange(range.location - 1, modelIdentifier.length - range.location + 1)];
    NSString *route = [[modelName lowercaseString] pluralizedString];
    if(action == APIUpdateKey || action == APIPatchKey || action == APIDeleteKey || action == APIShowKey) {
        route = [route stringByAppendingString:@"/self.identifier"];
    }
    return self.predefinedRoutes[classString][action][APIRouteKey] ?: route;
}

- (NSString *)methodForClassString:(NSString *)classString action:(NSString *)action {
    NSString *method = self.predefinedRoutes[classString][action][APIMethodKey] ?: [APIRouter APIActionMethods][action];
    return method;
}

- (NSDictionary *)requestParametersJSONKeyPathsByPropertyKey:(Class)class action:(NSString *)action {
    return self.predefinedRoutes[[class modelIdentifier]][action][APIRequestKey][@"parameters"] ?: [class keysForKeyPaths:@{APIActionKey : action}];
}

- (NSDictionary *)responseParametersJSONKeyPathsByPropertyKey:(Class)class action:(NSString *)action; {
    if(!action) {
        return nil;
    }
    return self.predefinedRoutes[[class modelIdentifier]][action][APIResponseKey][@"parameters"];
}

- (NSString *)requestTypeForClassString:(NSString *)classString action:(NSString *)action {
    NSDictionary *bindings = @{@"multipart" : APIRequestTypeMultipartData,
                               @"url" : APIRequestTypeURLEncoded,
                               @"raw" : APIRequestTypeRaw};
    return bindings[self.predefinedRoutes[classString][action][APIRequestKey][APITypeKey]] ?: APIRequestTypeURLEncoded;
}

- (BOOL)shouldParseWithClassString:(NSString *)classString action:(NSString *)action {
    NSNumber *shouldParseNumber = self.predefinedRoutes[classString][action][@"shouldParse"];
    BOOL shouldParse = shouldParseNumber ? [shouldParseNumber boolValue] : YES;
    return shouldParse;
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
        NSString *method = define[APIMethodKey];
        if(method.length) {
            [[self class] setMethod:method forKey:APIKey model:classString];
        }
        NSString *url = define[APIURLKey];
        if(url.length) {
            [[self class] setURL:url forKey:APIKey model:classString];
        }
        NSString *route = define[APIRouteKey];
        if(route.length) {
            [[self class] setRoute:route forKey:APIKey model:classString];
        }
    }
    [self.predefinedRoutes setObject:classRoutes forKey:classString];
}

+ (NSMutableDictionary *)APIActionImportTypes {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *bindings = nil;
    dispatch_once(&onceToken, ^{
        bindings = [[NSMutableDictionary alloc] init];
        [bindings addEntriesFromDictionary:@{APICreateKey :  @(APIImportTypeDictionary),
                                             APIIndexKey  :  @(APIImportTypeArray),
                                             APIShowKey   :  @(APIImportTypeDictionary),
                                             APIDeleteKey :  @(APIImportTypeNone),
                                             APIUpdateKey :  @(APIImportTypeDictionary),
                                             APIPatchKey  :  @(APIImportTypeDictionary)}];
    });
    return bindings;
}

+ (NSMutableDictionary *)APIActionMethods {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *bindings = nil;
    dispatch_once(&onceToken, ^{
        bindings = [[NSMutableDictionary alloc] init];
        [bindings addEntriesFromDictionary:@{APIIndexKey  : APIMethodGET,
                                             APIShowKey   : APIMethodGET,
                                             APIDeleteKey : APIMethodDELETE,
                                             APICreateKey : APIMethodPOST,
                                             APIUpdateKey : APIMethodPUT,
                                             APIPatchKey  : APIMethodPATCH}];
    });
    return bindings;
}

+ (NSDictionary *)APIConfigurationImportTypes {
    static NSDictionary *bindings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bindings = @{APIFormatArray : @(APIImportTypeArray),
                     APIFormatDictionary : @(APIImportTypeDictionary),
                     APIFormatNone : @(APIImportTypeNone)};
    });
    return bindings;
}

@end
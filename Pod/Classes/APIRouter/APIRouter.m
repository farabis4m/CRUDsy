//
//  APIRouter.m
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import "APIRouter.h"

NSString *const APIIndexKey = @"index";
NSString *const APICreateKey = @"create";
NSString *const APIShowKey = @"show";
NSString *const APIUpdateKey = @"update";
NSString *const APIDeleteKey = @"delete";

static NSMutableDictionary *definedRoutes = nil;
static NSMutableDictionary *definedURLs = nil;
static NSMutableDictionary *definedMethods = nil;

#import "NSObject+API.h"

@interface APIRouter ()

@property (nonatomic, strong) NSMutableArray *registeredClasses;

@property (nonatomic, strong) NSDictionary *predefinedRoutes;

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

+ (void)load {
}

#pragma mark - Setup

- (void)setup {
    self.registeredClasses = [NSMutableArray array];
    
    NSString *routesFilePath = [[NSBundle mainBundle] pathForResource:@"routes" ofType:@"plist"];
    BOOL isDirectory = NO;
    if([[NSFileManager defaultManager] fileExistsAtPath:routesFilePath isDirectory:&isDirectory]) {
        self.predefinedRoutes = [NSDictionary dictionaryWithContentsOfFile:routesFilePath];
        self.baseURL = self.predefinedRoutes[@"baseURL"];
    }
}

#pragma mark -

- (void)registerClass:(Class)class {
    NSString *classString = NSStringFromClass(class);
    [self.registeredClasses addObject:classString];
    [self flushRoutesForClass:[class modelString]];
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

- (NSDictionary *)routes {
    return definedRoutes;
}

- (NSDictionary *)baseURLs {
    return definedURLs;
}

- (NSDictionary *)methods {
    return definedMethods;
}

- (NSDictionary *)parametersWithClass:(Class)class {
    return self.predefinedRoutes[[class modelString]][@"parameters"];
}

- (NSDictionary *)JSONKeyPathsByPropertyKey:(Class)class {
    return self.predefinedRoutes[[class modelString]];
}

#pragma mark - Utils

- (void)flushRoutesForClass:(NSString *)classString {
    NSDictionary *classRoutes = self.predefinedRoutes[classString];
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
}

@end
//
//  APIDefaultURLBuilder.m
//  Pods
//
//  Created by Vlad Gorbenko on 3/21/16.
//
//

#import "APIDefaultURLBuilder.h"

#import "APIRouter.h"
#import "APIRouteKeys.h"

@implementation APIDefaultURLBuilder

#pragma mark - URL Building

- (NSString *)buildURLWithString:(NSString *)URLString {
    return URLString;
}

- (NSString *)buildURLWithModel:(NSString *)model action:(NSString *)action {
    APIRouter *router = [APIRouter sharedInstance];
    NSString *url = router.predefinedRoutes[model][action][APIURLKey] ?: [[APIRouter sharedInstance] baseURL];
    NSString *prefix = router.predefinedRoutes[model][action][APIPrefixKey] ?: router.defaultPrefix;
    if(prefix.length) {
        url = [NSString stringWithFormat:@"%@/%@", url, prefix];
    }
    return url;
}

@end

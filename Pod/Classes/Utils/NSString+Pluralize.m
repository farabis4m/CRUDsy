//
//  NSString+Pluralize.m
//  Pods
//
//  Created by vlad gorbenko on 8/13/15.
//
//

#import "NSString+Pluralize.h"

@implementation NSString (Pluralize)

- (NSString *)pluralize {
    return [NSString stringWithFormat:@"%@s", self];
}

@end

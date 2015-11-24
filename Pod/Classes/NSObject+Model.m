//
//  NSObject+Model.m
//  Pods
//
//  Created by vlad gorbenko on 11/18/15.
//
//

#import "NSObject+Model.h"

@implementation NSObject (Model)

+ (NSString *)modelIdentifier {
    NSString *className = NSStringFromClass([self class]);
    return [[className componentsSeparatedByString:@"."] lastObject];
}

@end

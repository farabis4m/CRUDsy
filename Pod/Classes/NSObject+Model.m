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
    return NSStringFromClass([self class]);
}

@end

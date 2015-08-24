//
//  NSValueTransformer+APIPredefinedTransformers.m
//  Pods
//
//  Created by vlad gorbenko on 8/24/15.
//
//

#import "NSValueTransformer+APIPredefinedTransformers.h"

#import <Mantle/MTLValueTransformer.h>

NSString *const MTLBoolValueTransformer = @"MTLBoolValueTransformer";
NSString *const MTLNumberValueTransformer = @"MTLNumberValueTransformer";

@implementation NSValueTransformer (APIPredefinedTransformers)

+ (void)load {
    MTLValueTransformer *booleanValueTransformer = [MTLValueTransformer transformerUsingReversibleBlock:^ id (id boolean, BOOL *success, NSError **error) {
        if (boolean == nil) return nil;
        if ([boolean isKindOfClass:NSNumber.class]) {
            NSNumber *boolValue = boolean;
            return (NSNumber *)(boolValue.boolValue ? kCFBooleanTrue : kCFBooleanFalse);
        } else if([boolean isKindOfClass:NSString.class]) {
            NSArray *boolTrueValues = @[@"y", @"yes", @"true", @"1"];
            NSArray *boolFalseValue = @[@"n", @"no", @"false", @"0"];
            if([boolTrueValues containsObject:boolean]) {
                return (NSNumber *)kCFBooleanTrue;
            } else if([boolFalseValue containsObject:boolean]) {
                return (NSNumber *)kCFBooleanFalse;
            }
        }
        return nil;
    }];
    [NSValueTransformer setValueTransformer:booleanValueTransformer forName:MTLBoolValueTransformer];

    MTLValueTransformer *numberValueTransformer = [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if(!value) return nil;
        if([value isKindOfClass:NSString.class]) {
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber *number = [f numberFromString:value];
            return number;
        }
        return nil;
    }];
    [NSValueTransformer setValueTransformer:numberValueTransformer forName:MTLNumberValueTransformer];
}

+ (NSValueTransformer *)mtl_numberValueTransformer {
    return [NSValueTransformer valueTransformerForName:MTLNumberValueTransformer];
}

+ (NSValueTransformer *)mtl_boolValueTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBoolValueTransformer];
}

@end

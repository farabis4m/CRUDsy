//
//  NSValueTransformer+APIPredefinedTransformers.h
//  Pods
//
//  Created by vlad gorbenko on 8/24/15.
//
//

#import <Foundation/Foundation.h>

@interface NSValueTransformer (APIPredefinedTransformers)

+ (NSValueTransformer *)mtl_numberValueTransformer;
+ (NSValueTransformer *)mtl_boolValueTransformer;

@end

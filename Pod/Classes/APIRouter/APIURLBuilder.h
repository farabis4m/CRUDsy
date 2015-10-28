//
//  APIURLBuilder.h
//  Pods
//
//  Created by vlad gorbenko on 10/28/15.
//
//

#import <Foundation/Foundation.h>

@protocol APIURLBuilder <NSObject>

- (NSString *)buildURLWithString:(NSString *)URLString;

@end

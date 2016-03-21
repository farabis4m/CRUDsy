//
//  APIURLBuilder.h
//  Pods
//
//  Created by vlad gorbenko on 10/28/15.
//
//

#import <Foundation/Foundation.h>

@protocol APIURLBuilder <NSObject>

@required
- (NSString *)buildURLWithString:(NSString *)URLString DEPRECATED_ATTRIBUTE;
- (NSString *)buildURLWithModel:(NSString *)model action:(NSString *)action;

@end

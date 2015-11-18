//
//  APIParserProtocol.h
//  Pods
//
//  Created by vlad gorbenko on 11/18/15.
//
//

#import <Foundation/Foundation.h>

@protocol APIParserProtocol <NSObject>

- (id)parse:(id)responseObject class:(Class)class action:(NSString *)action error:(NSError **)error model:(id)model;

@end

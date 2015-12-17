//
//  APIResponse.h
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import <Foundation/Foundation.h>

/**
 `FTAPIResponse` class is model that represents response from the server side.
 */
@interface APIResponse : NSObject

/**
 Response data from the server.
 */
@property (nonatomic, strong) id data;

/**
 Error object.
 */
@property (nonatomic, strong) NSError *error;

/**
 Current offset.
 */
@property (nonatomic, strong) id offset;

/**
 Total number of items.
 */
@property (nonatomic, strong) NSNumber *totalItemsCount;

/**
 Indicator does server has more items.
 */
@property (nonatomic, assign, readonly) BOOL hasNext;

/**
 User info dictionary to store additional parameters.
 */
@property (nonatomic, strong) NSDictionary *userInfo;

+ (instancetype)responseWithData:(id)data error:(NSError *)error;

@end

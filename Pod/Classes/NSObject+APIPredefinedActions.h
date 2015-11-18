//
//  NSObject+APIPredefinedActions.h
//  Pods
//
//  Created by vlad gorbenko on 11/18/15.
//
//

#import <Foundation/Foundation.h>

#import "APICompletionBlock.h"

#import "APIImportType.h"

@interface NSObject (APIPredefinedActions)

/**
 Method to add new item.
 Parameters: Transforms object to dictionary.
 URL: POST /items
 @param start starts operation immediately. Default is TRUE
 @param completionBlock completion block when operations is done
 */
- (NSOperation *)createWithCompletionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start;
- (NSOperation *)createWithCompletionBlock:(APIResponseCompletionBlock)completionBlock;

/**
 Method to add new item.
 Parameters: Attributes parameter.
 URL: POST /items
 @param attributes values for request serialization
 @param start starts operation immediately. Default is TRUE
 @param completionBlock completion block when operations is done
 */
+ (NSOperation *)createWithAttributes:(NSDictionary *)attributes completionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start;
+ (NSOperation *)createWithAttributes:(NSDictionary *)attributes completionBlock:(APIResponseCompletionBlock)completionBlock;

/**
 Method to retrieve list of items.
 URL: GET /items
 @param start starts operation immediately. Default is TRUE
 @param completionBlock completion block when operations is done
 */
+ (NSOperation *)listWithCompletionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start;
+ (NSOperation *)listWithCompletionBlock:(APIResponseCompletionBlock)completionBlock;

/**
 Method identical to list but with list of specified criterias like offset, length.
 URL: GET /items?p1=val1&p2=val2
 @param start starts operation immediately. Default is TRUE
 @param criterias array of criterias for request query
 @param completionBlock completion block when operations is done
 */
+ (NSOperation *)listWithCriterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start;
+ (NSOperation *)listWithCriterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock;

/**
 Method to get details of object.
 Based on id.
 /items/:id?p1=val1&p2=val2
 @param start starts operation immediately. Default is TRUE
 @param criterias array of criterias for request query
 @param completionBlock completion block when operations is done
 */
- (NSOperation *)showWithCriterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start;
- (NSOperation *)showWithCriterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock;
- (NSOperation *)showWithCompletionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start;
- (NSOperation *)showWithCompletionBlock:(APIResponseCompletionBlock)completionBlock;

/**
 Method to update item.
 URL: PUT /items/:id
 @param start starts operation immediately. Default is TRUE
 @param completionBlock completion block when operations is done
 */
- (NSOperation *)updateWithCompletionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start;
- (NSOperation *)updateWithCompletionBlock:(APIResponseCompletionBlock)completionBlock;

/**
 Method to patch item.
 URL: PATCH /items/:id
 @param start starts operation immediately. Default is TRUE
 @param completionBlock completion block when operations is done
 */
- (NSOperation *)patchWithCompletionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start;
- (NSOperation *)patchWithCompletionBlock:(APIResponseCompletionBlock)completionBlock;

/**
 Method to delete item.
 URL: DELETE /items/:id
 @param start starts operation immediately. Default is TRUE
 @param completionBlock completion block when operations is done
 */
- (NSOperation *)deleteWithCompletionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start;
- (NSOperation *)deleteWithCompletionBlock:(APIResponseCompletionBlock)completionBlock;

@end

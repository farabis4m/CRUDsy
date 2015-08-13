//
//  NSObject+API.h
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import <Foundation/Foundation.h>

#import "APICompletionBlock.h"

typedef NS_ENUM (NSInteger, APIImportType) {
    APIImportTypeArray,
    APIImportTypeDictionary,
    APIImportTypeNone
};

@interface NSObject (API)

/**
 Method to retrieve list of items.
 URL: GET /items
 */
+ (void)listWithCompletionBlock:(FTAPIResponseCompletionBlock)completionBlock;

/**
 Method identical to list but with list of specified criterias like offset, length.
 URL: GET /items?p1=val1&p2=val2
 */
+ (void)listWithCriterias:(NSArray *)criterias completionBlock:(FTAPIResponseCompletionBlock)completionBlock;

/**
 Method to get details of object.
 Based on id.
 /items/:id
 */
- (void)showWithCompletionBlock:(FTAPIResponseCompletionBlock)completionBlock;

/**
 Method to add new item.
 URL: POST /items
 */
- (void)createWithCompletionBlock:(FTAPIResponseCompletionBlock)completionBlock;

/**
 Method to update item.
 URL: PUT /items/:id
 */
- (void)updateWithCompletionBlock:(FTAPIResponseCompletionBlock)completionBlock;

/**
 Method to delete item.
 URL: DELETE /items/:id
 */
- (void)deleteWithCompletionBlock:(FTAPIResponseCompletionBlock)completionBlock;

+ (NSString *)modelString;
/**
 Method to launch request.
 @param key `NSString` object that represents key action from defined list. Also this value checked in routes.plist file.
 @param method Method of request. Must be value of predefined `NSString` object.
 @param route Relative URL string of request.
 @param criterias Array of criterias.
 @param importType Import type of expected response.
 @param completionBlock Block that will be called after request finished.
 */
+ (void)requestWithKey:(NSString *)key method:(NSString *)method route:(NSString *)route criterias:(NSArray *)criterias importType:(APIImportType)importType completionBlock:(FTAPIResponseCompletionBlock)completionBlock;

@end

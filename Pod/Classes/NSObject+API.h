//
//  NSObject+API.h
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import <Foundation/Foundation.h>

#import "APICompletionBlock.h"

#import "APIImportType.h"

@interface NSObject (API)

/**
 Method to perform action on model.
 @param action action name
 @param parameters array of parameters. Available parameters [[<Attribute>], [<Criteria>]] or {"criterias" => [], "attributes" => {}}
 */
- (NSOperation *)action:(NSString *)action parameters:(id)parameters completionBlock:(APIResponseCompletionBlock)completionBlock;
+ (NSOperation *)action:(NSString *)action parameters:(id)parameters completionBlock:(APIResponseCompletionBlock)completionBlock;

/**
 Method to perform action on model.
 @param action action name
 @param start starts operation immediately. Default is TRUE
 @param completionBlock completion block when operations is done
 */
- (NSOperation *)action:(NSString *)action criterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start;
- (NSOperation *)action:(NSString *)action criterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock;

+ (NSOperation *)action:(NSString *)action attributes:(NSDictionary *)attributes criterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock start:(BOOL)start;
+ (NSOperation *)action:(NSString *)action attributes:(NSDictionary *)attributes criterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock;

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
//+ (NSOperation *)requestWithKey:(NSString *)key method:(NSString *)method route:(NSString *)route criterias:(NSArray *)criterias completionBlock:(APIResponseCompletionBlock)completionBlock;

/**
 Method to launch request.
 @param key `NSString` object that represents key action from defined list. Also this value checked in routes.plist file.
 @param criterias Array of criterias.
 @param importType Import type of expected response.
 @param completionBlock Block that will be called after request finished.
 */
+ (NSOperation *)requestWithKey:(NSString *)key criterias:(NSArray *)criterias start:(BOOL)start completionBlock:(APIResponseCompletionBlock)completionBlock;

/**
 Method to launch request.
 @param key `NSString` object that represents key action from defined list. Also this value checked in routes.plist file.
 @param routeSource Class route definition that holds route info.
 @param criterias Array of criterias.
 @param importType Import type of expected response.
 @param completionBlock Block that will be called after request finished.
 */
+ (NSOperation *)requestWithKey:(NSString *)key routeSource:(Class)routeSource criterias:(NSArray *)criterias start:(BOOL)start completionBlock:(APIResponseCompletionBlock)completionBlock;
- (NSOperation *)requestWithKey:(NSString *)key routeSource:(Class)routeSource criterias:(NSArray *)criterias start:(BOOL)start completionBlock:(APIResponseCompletionBlock)completionBlock;

@end

//
//  APIPageCriteria.h
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import "APICriteria.h"

/**
 `APIPageCriteria` is model that represents criteria witch used to build parameters for request.
 */
@interface APIPageCriteria : APICriteria

/**
 Offset.
 */
@property (nonatomic, assign) NSInteger offset;

/**
 Number of expected items.
 */
@property (nonatomic, assign) NSInteger length;

+ (instancetype)criteriaWithOffset:(NSInteger)offset length:(NSInteger)legnth;

- (instancetype)initWithOffset:(NSInteger)offset length:(NSInteger)legnth;

@end

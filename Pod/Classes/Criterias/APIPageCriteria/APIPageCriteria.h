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
@property (nonatomic, strong) id offset;

/**
 Number of expected items.
 */
@property (nonatomic, strong) NSNumber *length;

+ (instancetype)criteriaWithOffset:(id)offset length:(NSNumber *)legnth;

- (instancetype)initWithOffset:(id)offset length:(NSNumber *)legnth;

@end

//
//  MTLRouteErrors.h
//  Pods
//
//  Created by vlad gorbenko on 8/16/15.
//
//

#import <Foundation/Foundation.h>

// Associated with the NSException that was caught.
static NSString * const MTLRouteJSONAdapterThrownExceptionErrorKey = @"MTLJSONAdapterThrownException";

/// The domain for errors originating from MTLJSONAdapter.
extern NSString * const MTLRouteJSONAdapterErrorDomain;

/// +classForParsingJSONDictionary: returned nil for the given dictionary.
extern const NSInteger MTLRouteJSONAdapterErrorNoClassFound;

/// The provided JSONDictionary is not valid.
extern const NSInteger MTLRouteJSONAdapterErrorInvalidJSONDictionary;

/// The model's implementation of +JSONKeyPathsByPropertyKey included a key which
/// does not actually exist in +propertyKeys.
extern const NSInteger MTLRouteJSONAdapterErrorInvalidJSONMapping;
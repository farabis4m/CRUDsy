//
//  MTLRouteErrors.m
//  Pods
//
//  Created by vlad gorbenko on 8/16/15.
//
//

#import "MTLRouteErrors.h"

NSString * const MTLRouteJSONAdapterErrorDomain = @"MTLJSONAdapterErrorDomain";
const NSInteger MTLRouteJSONAdapterErrorNoClassFound = 2;
const NSInteger MTLRouteJSONAdapterErrorInvalidJSONDictionary = 3;
const NSInteger MTLRouteJSONAdapterErrorInvalidJSONMapping = 4;

// An exception was thrown and caught.
const NSInteger MTLRouteJSONAdapterErrorExceptionThrown = 1;
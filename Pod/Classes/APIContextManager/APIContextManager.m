//
//  APIContextManager.m
//  Pods
//
//  Created by vlad gorbenko on 8/18/15.
//
//

#import "APIContextManager.h"

#import <MagicalRecord/NSManagedObjectContext+MagicalRecord.h>

@implementation APIContextManager

#pragma mark - Context management

- (NSManagedObjectContext *)contextForModelClass:(Class)class action:(NSString *)action {
    return [NSManagedObjectContext MR_defaultContext];
}

@end

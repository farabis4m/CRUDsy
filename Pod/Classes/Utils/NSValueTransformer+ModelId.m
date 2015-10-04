//
//  NSValueTransformer+ModelId.m
//  Pods
//
//  Created by vlad gorbenko on 10/4/15.
//
//

#import "NSValueTransformer+ModelId.h"

#import <FluentJ/FJValueTransformer.h>

#import "ModelIDProtocol.h"

NSString *const FJModelIdValueTransformer = @"FJModelIdValueTransformer";

@implementation NSValueTransformer (ModelId)

#pragma mark - Lifecycle

+ (void)load {
    
}

#pragma mark - Setup

- (void)setupModelTransformer {
    FJValueTransformer *modelTransformer = [FJValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if(![value conformsToProtocol:@protocol(ModelIDProtocol)]) {
            NSString *message = NSLocalizedString(@"Model doesn't conform ModelIDProtocol", nil);
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : message,
                                       NSLocalizedFailureReasonErrorKey: message};
            *error = [NSError errorWithDomain:@"com.CRUDsy.app" code:0 userInfo:userInfo];
            return nil;
        }
        id<ModelIDProtocol> model = value;
        return [model identifier];
    }];
    [NSValueTransformer setValueTransformer:modelTransformer forName:FJModelIdValueTransformer];
}

@end

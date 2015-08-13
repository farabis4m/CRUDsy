//
//  APIModelCriteria.m
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import "APIModelCriteria.h"

@implementation APIModelCriteria

#pragma mark - FTAPIModelCriteria lifecycle

+ (instancetype)criteriaWithModel:(id<ModelIDProtocol>)model {
    return [[self alloc] initWithModel:model];
}

- (instancetype)initWithModel:(id<ModelIDProtocol>)model {
    self = [super init];
    if(self) {
        self.model = model;
    }
    return self;
}

#pragma mark - JSON

- (NSDictionary *)JSON {
    if(self.model.identifier) {
        NSString *key = [[[self.model class] JSONKeyPathsByPropertyKey] objectForKey:@"identifier"];
        return @{key : self.model.identifier};
    }
    return @{};
}

@end

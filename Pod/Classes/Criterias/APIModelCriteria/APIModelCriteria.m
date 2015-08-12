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
    if(self.model.id) {
        NSString *key = [[[self.model class] JSONKeyPathsByPropertyKey] objectForKey:@"id"];
        return @{key : self.model.id};
    }
    return @{};
}


@end

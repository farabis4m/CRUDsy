//
//  APIModelCriteria.m
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import "APIModelCriteria.h"

#import <FluentJ/FluentJ.h>

@implementation APIModelCriteria

#pragma mark - FTAPIModelCriteria lifecycle

+ (instancetype)criteriaWithModel:(id<ModelIDProtocol>)model {
    return [[self alloc] initWithModel:model];
}

+ (NSArray *)criteriasWithModels:(NSArray *)models {
    NSMutableArray *criterias = [NSMutableArray array];
    for(id<ModelIDProtocol> model in models) {
        APICriteria *criteria = [APIModelCriteria criteriaWithModel:model];
        [criterias addObject:criteria];
    }
    return criterias;
}

- (instancetype)initWithModel:(id<ModelIDProtocol>)model {
    self = [super init];
    if(self) {
        self.model = model;
    }
    return self;
}

#pragma mark - Export

- (id)exportWithUserInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing  _Nullable *)error {
    if([self.model conformsToProtocol:@protocol(ModelIDProtocol)]) {
        if(self.model.identifier) {
            id keys = [[self.model class] keysForKeyPaths:self.userInfo][@"identifier"];
            NSString *key = [keys isKindOfClass:[NSArray class]] ? [keys firstObject] : keys;
            if(key.length) {
                return @{key : self.model.identifier};
            }
        }
    }
    return @{};
}

@end

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

#pragma mark - Lifecycle

+ (instancetype)criteriaWithModel:(id<ModelIDProtocol>)model {
    return [[self alloc] initWithModel:model];
}

+ (instancetype)criteriaWithModel:(id<ModelIDProtocol>)model template:(NSString *)template {
    return [[self alloc] initWithModel:model template:template];
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
    return [self initWithModel:model template:nil];
}

- (instancetype)initWithModel:(id<ModelIDProtocol>)model template:(NSString *)template {
    self = [super init];
    if(self) {
        self.model = model;
        self.templateKey = template;
        self.type = APIPathCriteriaType;
    }
    return self;
}

#pragma mark - Export

- (id)exportWithUserInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing  _Nullable *)error {
    if([self.model conformsToProtocol:@protocol(ModelIDProtocol)] && self.templateKey.length == 0) {
        if(self.model.identifier) {
            NSMutableDictionary *fullInfo = [NSMutableDictionary dictionary];
            [fullInfo addEntriesFromDictionary:userInfo];
            [fullInfo addEntriesFromDictionary:self.userInfo];
            id keys = [[self.model class] keysForKeyPaths:userInfo][@"identifier"];
            NSString *key = [keys isKindOfClass:[NSArray class]] ? [keys firstObject] : keys;
            if(key.length) {
                return @{key : self.model.identifier};
            }
        }
    }
    return @{};
}

@end

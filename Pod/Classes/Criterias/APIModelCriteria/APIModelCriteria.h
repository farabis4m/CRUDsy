//
//  APIModelCriteria.h
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import "APICriteria.h"

#import "ModelIDProtocol.h"

@interface APIModelCriteria : APICriteria

@property (nonatomic, strong) id<ModelIDProtocol> model;

+ (instancetype)criteriaWithModel:(id<ModelIDProtocol>)model;
+ (NSArray *)criteriasWithModels:(NSArray *)models;

- (instancetype)initWithModel:(id<ModelIDProtocol>)model;

@end

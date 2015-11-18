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
@property (nonatomic, strong) NSString *templateKey;

+ (instancetype)criteriaWithModel:(id<ModelIDProtocol>)model;
+ (instancetype)criteriaWithModel:(id<ModelIDProtocol>)model template:(NSString *)template;

/**
 Populate ccriterias with array of models.
 Array of models -> Array of criterias.
 */
+ (NSArray *)criteriasWithModels:(NSArray *)models;

/**
 Init with model.
 @param model instance of some model.
 */
- (instancetype)initWithModel:(id<ModelIDProtocol>)model;

/**
 Init with model and template.
 @param model instance of some model.
 @param template template key which represents keyPath template.
 */
- (instancetype)initWithModel:(id<ModelIDProtocol>)model template:(NSString *)template;

@end

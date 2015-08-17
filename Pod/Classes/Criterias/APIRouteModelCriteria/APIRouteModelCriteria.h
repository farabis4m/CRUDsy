//
//  APIRouteModelCriteria.h
//  Pods
//
//  Created by vlad gorbenko on 8/13/15.
//
//

#import "APIModelCriteria.h"

@interface APIRouteModelCriteria : APIModelCriteria

@property (nonatomic, strong) NSString *action;

+ (instancetype)criteriaWithModel:(id<ModelIDProtocol>)model action:(NSString *)action;

@end

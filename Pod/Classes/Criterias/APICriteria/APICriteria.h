//
//  APICriteria.h
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>

@interface APICriteria : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSDictionary *userInfo;

@end
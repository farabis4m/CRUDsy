//
//  ModelIDProtocol.h
//  Pods
//
//  Created by vlad gorbenko on 8/12/15.
//
//

#import <Foundation/Foundation.h>

/**
 `ModelIDProtocol` describes base relational model behaviour.
 */
@protocol ModelIDProtocol <NSObject>

@required
/**
 The identifier of some model
 */
@property (nonatomic, strong) id id;

@end

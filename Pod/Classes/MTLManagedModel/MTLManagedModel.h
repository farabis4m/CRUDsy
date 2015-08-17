//
//  MTLManagedModel.h
//  Pods
//
//  Created by vlad gorbenko on 8/16/15.
//
//

#import <CoreData/CoreData.h>

#import <Mantle/MTLModel.h>

#import "MTLRouteJSONSerializing.h"
#import "ModelIDProtocol.h"

@interface MTLManagedModel : NSManagedObject <MTLModel, MTLRouteJSONSerializing, ModelIDProtocol>

@property (nonatomic, retain) id identifier;

@end

//
//  APIJSONAdapter.m
//  Pods
//
//  Created by vlad gorbenko on 8/13/15.
//
//

#import "APIJSONAdapter.h"

#import "APIRouter.h"

#import "NSObject+API.h"

@implementation APIJSONAdapter

- (NSSet *)serializablePropertyKeys:(NSSet *)propertyKeys forModel:(id<MTLJSONSerializing>)model {
    NSString *modelString = [[model class] modelString];
    NSDictionary *parameters = [APIRouter sharedInstance].routes[modelString][@"parameters"];
    if(parameters.count) {
        NSSet *set = [NSSet setWithArray:parameters.allKeys];
        return set;
    }
    return [super serializablePropertyKeys:propertyKeys forModel:model];
}

@end

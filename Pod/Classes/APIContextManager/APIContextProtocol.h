//
//  APIContextProtocol.h
//  Pods
//
//  Created by vlad gorbenko on 8/18/15.
//
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@protocol APIContextProtocol <NSObject>

@required
- (NSManagedObjectContext *)contextForModelClass:(Class)class action:(NSString *)action;

@end

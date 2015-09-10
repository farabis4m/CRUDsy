//
//  Book.h
//  CRUDsy
//
//  Created by vlad gorbenko on 8/17/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Author;

@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) Author *author;

@end

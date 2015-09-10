//
//  Author.h
//  CRUDsy
//
//  Created by vlad gorbenko on 8/17/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Book;

@interface Author : NSManagedObject

@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSSet *books;

- (NSString *)fullname;

@end

@interface Author (CoreDataGeneratedAccessors)

- (void)addBooksObject:(Book *)value;
- (void)removeBooksObject:(Book *)value;
- (void)addBooks:(NSSet *)values;
- (void)removeBooks:(NSSet *)values;

@end

//
//  BooksViewController.h
//  CRUDsy
//
//  Created by vlad gorbenko on 8/17/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Author;

@interface BooksViewController : UITableViewController

@property (nonatomic, strong) Author *author;

@end

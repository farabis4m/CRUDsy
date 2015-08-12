//
//  APIUserTableViewCell.h
//  CRUDsy
//
//  Created by vlad gorbenko on 8/12/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APIUser;

@interface APIUserTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *fullnameLabel;
@property (nonatomic, weak) IBOutlet UILabel *ageLabel;
@property (nonatomic, weak) IBOutlet UIImageView *idImageView;

- (void)setupWithUser:(APIUser *)user;

@end

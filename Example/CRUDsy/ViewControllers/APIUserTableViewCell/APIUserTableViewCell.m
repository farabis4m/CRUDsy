//
//  APIUserTableViewCell.m
//  CRUDsy
//
//  Created by vlad gorbenko on 8/12/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import "APIUserTableViewCell.h"

#import "APIUser.h"

@implementation APIUserTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Setup

- (void)setupWithUser:(APIUser *)user {
    self.fullnameLabel.text = [user fullname];
    self.ageLabel.text = [NSString stringWithFormat:@"%ld years old", (long)user.age];
    SEL selector = NSSelectorFromString(@"setImageWithString:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.imageView performSelector:selector withObject:@"AA"];
#pragma clang diagnostic pop
}

@end

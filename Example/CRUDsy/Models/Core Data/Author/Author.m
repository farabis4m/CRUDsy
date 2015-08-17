//
//  Author.m
//  CRUDsy
//
//  Created by vlad gorbenko on 8/17/15.
//  Copyright (c) 2015 vlad gorbenko. All rights reserved.
//

#import "Author.h"

@implementation Author

@dynamic firstname;
@dynamic lastname;
@dynamic books;

- (NSString *)fullname {
    return [NSString stringWithFormat:@"%@ %@", self.firstname, self.lastname];
}

#pragma mark - BKRecursive description

//- (void)bk_addRecursiveDescriptionToString:(NSMutableString *)string level:(NSUInteger)level {
//    DESCRIBE_SELF(string, self);
//    
//    DESCRIBE_VARIABLE(string, level, _model); // CGRect
//    DESCRIBE_VARIABLE(string, level, _sections); // CGFloat
//    DESCRIBE_VARIABLE(string, level, _extra); // enum
//}

@end

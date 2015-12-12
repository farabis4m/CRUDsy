//
//  CRUDAttachement.m
//  Pods
//
//  Created by vlad gorbenko on 12/7/15.
//
//

#import "CRUDAttachement.h"

@implementation CRUDAttachement

#pragma mark - Lifecycle

+ (instancetype)attachementWithData:(NSData *)data mimeType:(NSString *)mimeType filename:(NSString *)filename {
    return [[self alloc] initWithData:data mimeType:mimeType filename:filename];
}

- (instancetype)initWithData:(NSData *)data mimeType:(NSString *)mimeType filename:(NSString *)filename {
    self = [super init];
    if(self) {
        self.data = data;
        self.mimeType = mimeType;
        self.filename = filename;
    }
    return self;
}

@end

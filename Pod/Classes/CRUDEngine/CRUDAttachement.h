//
//  CRUDAttachement.h
//  Pods
//
//  Created by vlad gorbenko on 12/7/15.
//
//

#import <Foundation/Foundation.h>

@interface CRUDAttachement : NSObject

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSString *filename;

+ (instancetype)attachementWithData:(NSData *)data mimeType:(NSString *)mimeType filename:(NSString *)filename;
+ (instancetype)attachementWithURL:(NSURL *)url;

- (instancetype)initWithData:(NSData *)data mimeType:(NSString *)mimeType filename:(NSString *)filename;

@end

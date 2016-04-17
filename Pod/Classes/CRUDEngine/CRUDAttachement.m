//
//  CRUDAttachement.m
//  Pods
//
//  Created by vlad gorbenko on 12/7/15.
//
//

#import "CRUDAttachement.h"

#import "MIMEType.h"

@interface CRUDAttachement ()

@property (nonatomic, strong) NSURL *fileURL;

@end

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

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if(self) {
        self.fileURL = url;
        self.mimeType = MIMETypeByFilename(url.absoluteString);
        self.filename = [url.absoluteString lastPathComponent];
    }
    return self;
}

+ (instancetype)attachementWithURL:(NSURL *)url {
    return [[self alloc] initWithURL:url];
}

#pragma mark - Accessors

- (NSData *)data {
    if(_fileURL) {
        return [NSData dataWithContentsOfURL:self.fileURL];
    }
    return _data;
}

@end

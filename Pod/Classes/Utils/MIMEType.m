//
//  MIMEType.m
//  Pods
//
//  Created by Vlad Gorbenko on 4/17/16.
//
//

#import "MIMEType.h"

NSString *MIMETypeByFilename(NSString *filename) {
    NSString *lastPathComponent = [filename lastPathComponent];
    NSString *extension = [lastPathComponent pathExtension];
    //TODO: Extract and add ability to register mime types
    NSDictionary *bindings = @{@"json" : @"application/json",
                               @"txt" : @"text/plain",
                               @"jpeg" : @"image/jpeg",
                               @"jpg" : @"image/jpeg"};
    return bindings[extension];
}

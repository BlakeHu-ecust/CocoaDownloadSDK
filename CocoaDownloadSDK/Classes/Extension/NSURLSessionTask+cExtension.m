//
//  NSURLSessionTask+cExtension.m
//  CocoaDownloadSDK
//
//  Created by 胡越 on 2020/4/2.
//

#import "NSURLSessionTask+cExtension.h"
#import <objc/runtime.h>

#define cIdentifierKey @"identifierKey"

@implementation NSURLSessionTask(cExtension)

- (void)setIdentifier:(NSString *)identifier{
    objc_setAssociatedObject(self, cIdentifierKey, identifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)identifier {
  return objc_getAssociatedObject(self, cIdentifierKey);
}

@end

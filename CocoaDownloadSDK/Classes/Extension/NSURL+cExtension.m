//
//  NSURL+cExtension.m
//  CocoaDownloadSDK
//
//  Created by 胡越 on 2020/4/2.
//

#import "NSURL+cExtension.h"

@implementation NSURL(cExtension)

- (NSString *)getLastPathComponent{
    NSString *pathComponent = [self lastPathComponent];
    NSRange range = [pathComponent rangeOfString:@"?"];
    if (range.location > 0 && range.length == 1) {
        pathComponent = [pathComponent substringToIndex:range.location];
    }
    return pathComponent;
}

@end

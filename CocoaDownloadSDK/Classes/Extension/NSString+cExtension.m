//
//  NSString+cExtension.m
//  CocoaDownloadSDK
//
//  Created by 胡越 on 2020/4/10.
//

#import "NSString+cExtension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString(cExtension)

- (NSString *)md5{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    
    return result;
}

@end

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CocoaDownloadConfig.h"
#import "CocoaDownloadManager.h"
#import "CocoaDownloadSDK.h"
#import "CocoaDownloadSession.h"
#import "CocoaDownloadTask.h"
#import "CocoaNormalTableViewCell.h"
#import "NSURL+cExtension.h"
#import "NSURLSessionTask+cExtension.h"
#import "Reachability.h"
#import "AESCrypt.h"
#import "NSData+Base64.h"
#import "NSData+CommonCrypto.h"
#import "NSString+Base64.h"

FOUNDATION_EXPORT double CocoaDownloadSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char CocoaDownloadSDKVersionString[];


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
#import "NSString+cExtension.h"
#import "NSURL+cExtension.h"
#import "NSURLSessionTask+cExtension.h"

FOUNDATION_EXPORT double CocoaDownloadSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char CocoaDownloadSDKVersionString[];


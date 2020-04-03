//
//  UITableViewCell+cExtension.h
//  CocoaDownloadSDK
//
//  Created by 胡越 on 2020/3/27.
//

#import <Foundation/Foundation.h>
#import "CocoaNormalTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class CocoaDownloadTask;
@interface CocoaNormalTableViewCell(cExtension)

@property (nonatomic, strong) CocoaDownloadTask *task;

@end

NS_ASSUME_NONNULL_END

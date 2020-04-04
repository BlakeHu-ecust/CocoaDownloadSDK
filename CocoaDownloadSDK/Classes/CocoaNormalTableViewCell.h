//
//  CocoaNormalTableViewCell.h
//  CocoaDownloadSDK
//
//  Created by 胡越 on 2020/4/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CocoaDownloadTask;
@interface CocoaNormalTableViewCell : UITableViewCell

@property (nonatomic, strong) CocoaDownloadTask *task;

- (void)setUI;

@end

NS_ASSUME_NONNULL_END

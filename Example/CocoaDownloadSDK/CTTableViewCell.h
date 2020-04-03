//
//  CTTableViewCell.h
//  CocoaDownloadSDK_Example
//
//  Created by 胡越 on 2020/3/27.
//  Copyright © 2020 695081933@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTTableViewCell : CocoaNormalTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIButton *startOrPauseBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

NS_ASSUME_NONNULL_END

//
//  CTTableViewCell.m
//  CocoaDownloadSDK_Example
//
//  Created by 胡越 on 2020/3/27.
//  Copyright © 2020 695081933@qq.com. All rights reserved.
//

#import "CTTableViewCell.h"

@implementation CTTableViewCell

- (IBAction)start:(id)sender {
    NSLog(@"%@开始、暂停",self.task.title);
    [self.task startOrSuspend];
}

- (void)setUI{
    [super setUI];
    self.nameLabel.text = self.task.title;
    self.progressView.progress = self.task.progress;
    self.fileSizeLabel.text = [NSByteCountFormatter stringFromByteCount:self.task.fileSize countStyle:NSByteCountFormatterCountStyleBinary];
    NSString *statusLabel;
    switch (self.task.status) {
        case Running:
        case Suspended:
            statusLabel = [NSString stringWithFormat:@"已下载:%.1f%%",self.task.progress*100];
            break;
        case None :
            statusLabel = @"准备下载";
            break;
        case Completed:
            statusLabel = @"下载完成";
            break;
        case Failed:
            statusLabel = @"下载失败";
            break;
        case Waiting:
            statusLabel = @"等待中";
            break;
        default:
            break;
    }
    self.progressLabel.text = statusLabel;
    [self.startOrPauseBtn setSelected:self.task.status == Running];
    [self.startOrPauseBtn setHidden:self.task.status == Completed];
}

@end

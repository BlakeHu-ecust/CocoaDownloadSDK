//
//  UITableViewCell+cExtension.m
//  CocoaDownloadSDK
//
//  Created by 胡越 on 2020/3/27.
//

#import "CocoaNormalTableViewCell+cExtension.h"
#import <objc/runtime.h>
#import "CocoaDownloadTask.h"

#define cDownloadTaskKey @"cDownloadTaskKey"

@implementation CocoaNormalTableViewCell(cExtension)

- (void)setTask:(CocoaDownloadTask *)task{
    objc_setAssociatedObject(self, cDownloadTaskKey, task, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    __weak typeof(self) weakSelf = self;
    task.statusChangedBlock = ^(CocoaDownloadTask * _Nonnull task) {
       [weakSelf setUI];
    };
}

- (CocoaDownloadTask *)task {
  return objc_getAssociatedObject(self, cDownloadTaskKey);
}

@end

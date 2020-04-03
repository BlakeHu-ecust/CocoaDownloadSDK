//
//  DownloadTask.h
//  CocoaDownloadSDK
//
//  Created by 胡越 on 2020/3/20.
//  Copyright © 2020 chinatelecom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DownloadTaskStatus) {
    None = 0, // 初始状态
    Running,// 下载中
    Suspended,// 下载暂停
    Completed,// 下载完成
    Failed,// 下载失败
    Waiting// 等待下载
};


@class CocoaDownloadTask;

typedef void (^statusChanged) (CocoaDownloadTask *task);

@protocol DownloadTaskDelegate <NSObject>

@required
- (void)taskStatusChanged:(CocoaDownloadTask *)task;

- (void)downloadTask:(CocoaDownloadTask *)task downloadedSize:(int64_t)downloadedSize totalSize:(int64_t)totalSize;

@end

@interface CocoaDownloadTask : NSObject<NSCoding>
//主键
@property (nonatomic, copy, readonly) NSString *task_id;
//任务状态
@property (nonatomic, assign) DownloadTaskStatus status;
//文件标题
@property (nonatomic, copy) NSString *title;
//下载地址
@property (nonatomic, strong) NSURL *download_url;
//本地地址
@property (nonatomic, copy) NSString *localPath;
//文件大小
@property (nonatomic, assign) int64_t fileSize;
//缓存数据
@property (nonatomic, copy) NSString *resumeData;
//下载进度(0--100)
@property (nonatomic, assign) CGFloat progress;
//创建时间
@property (nonatomic, strong, readonly) NSDate *createDate;

@property (nonatomic, strong) NSURLSessionDownloadTask *task;

@property (nonatomic, copy) statusChanged statusChangedBlock;

@property (nonatomic, weak) id <DownloadTaskDelegate> delegate;

- (instancetype)initWithDownloadUrl:(NSURL *)url;

- (instancetype)initWithDownloadUrl:(NSURL *)url title:(NSString *)title;

- (BOOL)saveResumedData:(NSData *)data;

- (NSData *)readResumedData;

- (void)cleanResumedData;

/**
开始或暂停当前任务
*/
- (void)startOrSuspend;

/**
获取当前任务下载文件地址
@return 返回文件地址
*/
- (NSString *)getAbsoluteDownloadPath;

- (void)remove;

@end

NS_ASSUME_NONNULL_END

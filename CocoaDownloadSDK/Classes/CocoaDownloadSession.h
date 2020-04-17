//
//  CocoaDownloadSession.h
//  CocoaDownloadSDK
//
//  Created by 胡越 on 2020/3/25.
//

#import <Foundation/Foundation.h>
#import "CocoaDownloadTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface CocoaDownloadSession : NSObject

+ (instancetype)sharedSession;

/**
重置当前下载session
*/
- (void)invalidAndRestartSession;

/**
开始下载任务
@param task  下载任务
*/

- (void)startTask:(CocoaDownloadTask *)task;

/**
暂停下载任务
@param task  下载任务
*/
- (void)suspendTask:(CocoaDownloadTask *)task;

/**
开始所有任务
*/
- (void)startAllTasks;
/**
暂停所有任务
*/
- (void)suspendAllTasks;

/**
暂停所有任务
*/
- (void)saveAllTasksStatus;

@property (nonatomic, strong) NSMutableArray *tasksList;

@end

NS_ASSUME_NONNULL_END


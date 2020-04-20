//
//  CocoaDownloadManager.h
//  CocoaDownloadSDK
//
//  Created by 胡越 on 2020/3/25.
//

#import <Foundation/Foundation.h>
#import "CocoaDownloadTask.h"

typedef NS_ENUM(NSUInteger, DownloadTaskError) {
    DownloadTaskErrorNone = 0,
    DownloadTaskErrorDuplicateDownload,//重复任务
    DownloadTaskErrorInvalidURL,//无效URL
    DownloadTaskErrorInvalidPath,//无效存储地址
    DownloadTaskErrorInvalidSpcae,//存储空间不足
    DownloadTaskErrorInvalidNetWork,//当前没有网络
    DownloadTaskErrorCellular//当前蜂窝网
};

typedef NS_ENUM(NSUInteger, DownloadTaskConfig) {
    DownloadTaskConfigNone = 0,//不处理，直接返回
    DownloadTaskConfigReplace,//替换原有文件
    DownloadTaskConfigCreate,//创建新的复制文件
};

typedef void (^tasksStatusChanged) (NSArray *tasks);

@protocol DownloadManagerDelegate <NSObject>

@required
- (void)downloadTaskStatusChanged:(NSArray<CocoaDownloadTask *> *)tasks;

@end

@interface CocoaDownloadManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, copy) tasksStatusChanged tasksChangedBlock;

@property (nonatomic, weak) id <DownloadManagerDelegate> delegate;

/**
创建任务 通过传入下载链接URL和配置信息创建下载任务
@param url  下载URL
@param error  错误信息
@return 下载任务
*/
- (CocoaDownloadTask *)startTaskWithUrl:(NSURL *)url error:(DownloadTaskError *)error;

/**
创建任务 通过传入下载链接URL和配置信息创建下载任务
@param url  下载URL
@param title 文件名称
@param error  错误信息
@return 下载任务
*/
- (CocoaDownloadTask *)startTaskWithUrl:(NSURL *)url title:(NSString *)title error:(DownloadTaskError *)error;

/**
创建任务 通过传入下载链接URL和配置信息创建下载任务
@param url  下载URL
@param title 文件名称
@param config  下载任务配置选项
@param error  错误信息
@return 下载任务
*/
- (CocoaDownloadTask *)startTaskWithUrl:(NSURL *)url title:(NSString *)title config:(DownloadTaskConfig)config error:(DownloadTaskError *)error;
    
/**
开始一项下载任务
@param task  下载任务
*/
- (void)startDownloadTask:(CocoaDownloadTask *)task;

/**
暂停一项下载任务
@param task  下载任务
*/
- (void)suspendDownloadTask:(CocoaDownloadTask *)task;

/**
删除下载任务
@param task  下载任务
*/
- (void)removeDownloadTask:(CocoaDownloadTask *)task;

/**
根据id搜索下载任务
@param taskId  下载任务id
@return 下载任务实例
*/
- (CocoaDownloadTask *)getDownloadTaskByTaskId:(NSString *)taskId;

/**
设置任务默认下载模式
@param config  下载模式，默认None
*/
- (void)setDefalutMode:(DownloadTaskConfig)config;

/**
设置任务默认下载地址
@param path         下载地址，默认Download，设置时直接传文件夹名称比如（Download、Download/Vedio），自动存储在沙盒Documents文件夹中
*/
- (void)setDefalutDownloadPath:(NSString *)path;

/**
设置打开蜂窝网下载，默认打开
*/
- (void)enableCellular;

/**
设置关闭蜂窝网下载
*/
- (void)disableCellular;

- (void)cleanAllTasks;

@end

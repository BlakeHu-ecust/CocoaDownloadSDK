//
//  CocoaDownloadManager.m
//  CocoaDownloadSDK
//
//  Created by 胡越 on 2020/3/25.
//

#import "CocoaDownloadManager.h"
#import "CocoaDownloadConfig.h"
#import "CocoaDownloadSession.h"
#import "CocoaDownloadTask.h"
#import "AFNetworking.h"
#import "NSURL+cExtension.h"
//单例
static CocoaDownloadManager *shared = nil;


@interface CocoaDownloadManager()
@property (nonatomic, assign) AFNetworkReachabilityStatus networkStatus;
//当前所有任务
@property (nonatomic, strong) NSMutableArray *tasksList;
@end


@implementation CocoaDownloadManager{
    NSMutableArray *_tasksList;
}

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (shared == nil) {
            shared = [[[self class] alloc] init];
        }
    });
    return shared;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initNetWorkConfig];
        
        [self initDownloadPath];
        
        if (![fileManager fileExistsAtPath:Db_Path]) {
            [fileManager createDirectoryAtPath:Db_Path withIntermediateDirectories:YES attributes:nil error:nil];
        }

        //从数据库加载当前所有下载任务信息
        self.tasksList = [NSKeyedUnarchiver unarchiveObjectWithFile:[Db_Path stringByAppendingPathComponent:@"task.db"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)initNetWorkConfig{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    __weak typeof(self) weakSelf = self;
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        weakSelf.networkStatus = status;
        if (weakSelf.networkStatus == AFNetworkReachabilityStatusReachableViaWWAN && [[NSUserDefaults standardUserDefaults]boolForKey:cDisableCellular]) {
            [[CocoaDownloadSession sharedSession] invalidAndRestartSession];
        }
    }];
}

- (void)initDownloadPath{
    NSString *absolutePath = [defaultDownloadDir stringByExpandingTildeInPath];
    if (![fileManager fileExistsAtPath:absolutePath]) {
        [fileManager createDirectoryAtPath:absolutePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark - 创建新任务
- (CocoaDownloadTask *)startTaskWithUrl:(NSURL *)url error:(DownloadTaskError *)error{
    return [self startTaskWithUrl:url title:nil config:defaultDownloadMode error:error];
}

- (CocoaDownloadTask *)startTaskWithUrl:(NSURL *)url title:(NSString *)title error:(DownloadTaskError *)error{
    return [self startTaskWithUrl:url title:title config:defaultDownloadMode error:error];
}

- (CocoaDownloadTask *)startTaskWithUrl:(NSURL *)url title:(NSString *)title config:(DownloadTaskConfig)config error:(DownloadTaskError *)error{
    if (self.networkStatus == AFNetworkReachabilityStatusNotReachable || self.networkStatus == AFNetworkReachabilityStatusUnknown) {
        *error = DownloadTaskErrorInvalidNetWork;
        NSLog(@"网络环境异常");
        return nil;
    }
    if (self.networkStatus == AFNetworkReachabilityStatusReachableViaWWAN && [[NSUserDefaults standardUserDefaults]boolForKey:cDisableCellular]) {
        *error = DownloadTaskErrorCellular;
        NSLog(@"非法蜂窝网下载");
        return nil;
    }
    
    CocoaDownloadTask *task = [[CocoaDownloadTask alloc]initWithDownloadUrl:url title:title];
    NSString *destination = [task getAbsoluteDownloadPath];
    
    if (config != DownloadTaskConfigCreate && [self checkIsTaskExist:task]) {
        *error = DownloadTaskErrorDuplicateDownload;
        return nil;
    }
    
    if ([fileManager fileExistsAtPath:destination]) {
        switch (config) {
            case DownloadTaskConfigNone:{
                *error = DownloadTaskErrorDuplicateDownload;
                return nil;
            }
            case DownloadTaskConfigCreate:{
                while ([fileManager fileExistsAtPath:destination]) {
                    NSString *newName = [destination lastPathComponent];
                    destination = [destination stringByDeletingLastPathComponent];
                    //创建新的文件
                    NSRange range = [newName rangeOfString:@"."];
                    if (range.length) {
                        NSMutableString *newPath = [[NSMutableString alloc]initWithString:newName];
                        [newPath insertString:@"(1)" atIndex:range.location];
                        newName = newPath;
                    }
                    else{
                        newName = [newName stringByAppendingString:@"(1)"];
                    }
                    destination = [destination stringByAppendingPathComponent:newName];
                }
                task = [[CocoaDownloadTask alloc]initWithDownloadUrl:url title:[destination lastPathComponent]];
                break;
            }
            case DownloadTaskConfigReplace:
                [fileManager removeItemAtPath:destination error:nil];
                break;
        }
    }
    
    if ([self checkIsTaskExist:task]) {
        *error = DownloadTaskErrorDuplicateDownload;
        return nil;
    }
    
    [task startOrSuspend];
    
    *error = DownloadTaskErrorNone;
    return task;
}

#pragma mark - 开始已有任务
- (void)startDownloadTask:(CocoaDownloadTask *)task{
    [[CocoaDownloadSession sharedSession]startTask:task];
}

#pragma mark - 暂停已有任务
- (void)suspendDownloadTask:(CocoaDownloadTask *)task{
    [[CocoaDownloadSession sharedSession]suspendTask:task];
}

#pragma mark - 删除任务
- (void)removeDownloadTask:(CocoaDownloadTask *)task{
    [task remove];
    NSMutableArray *temArray = [self.tasksList mutableCopy];
    [temArray removeObject:task];
    self.tasksList = temArray;
    task = nil;
}

- (CocoaDownloadTask *)getDownloadTaskByTaskId:(NSString *)taskId{
    for (CocoaDownloadTask *task in self.tasksList) {
        if ([task.task_id isEqual:taskId]) {
            return task;
        }
    }
    return nil;
}

- (BOOL)checkIsTaskExist:(CocoaDownloadTask *)task{
    for (CocoaDownloadTask *tem in self.tasksList) {
        if ([tem.task_id isEqualToString:task.task_id]) {
            NSLog(@"已有相同任务");
            return YES;
        }
    }
    return NO;
}

#pragma mark - 设置默认下载地址
- (void)setDefalutDownloadPath:(NSString *)path{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"~/Documents/%@/",path] forKey:cDefaultDownloadPath];
    [self initDownloadPath];
}

#pragma mark - 设置默认下载模式
- (void)setDefalutMode:(DownloadTaskConfig)config{
    [[NSUserDefaults standardUserDefaults] setInteger:config forKey:cDefaultDownloadMode];
}

#pragma mark - 设置是否允许蜂窝网下载
//允许蜂窝网下载
- (void)enableCellular{
    [self setAllowCellular:YES];
    NSLog(@"蜂窝网已打开");
}
//禁止蜂窝网下载
- (void)disableCellular{
    [self setAllowCellular:NO];
    NSLog(@"蜂窝网已关闭");
}

- (void)setAllowCellular:(BOOL)allow{
    [[NSUserDefaults standardUserDefaults] setBool:!allow forKey:cDisableCellular];
    //当前是蜂窝网状态，暂停所有任务
    if (_networkStatus == AFNetworkReachabilityStatusReachableViaWWAN && !allow) {
        [[CocoaDownloadSession sharedSession] invalidAndRestartSession];
    }
}

- (void)cleanAllTasks{
    for (CocoaDownloadTask *task in self.tasksList) {
        [task remove];
    }
    [self.tasksList removeAllObjects];
}

#pragma mark - 懒加载
- (void)setTasksList:(NSMutableArray *)tasksList{
    _tasksList = tasksList ? tasksList : [NSMutableArray new];
    [CocoaDownloadSession sharedSession].tasksList = _tasksList;
    if (self.tasksChangedBlock) {
        self.tasksChangedBlock(_tasksList);
    }
    if ([self.delegate respondsToSelector:@selector(downloadTaskStatusChanged:)]) {
        [self.delegate downloadTaskStatusChanged:_tasksList];
    }
}

- (NSMutableArray *)tasksList{
    if (!_tasksList) {
        _tasksList = [NSMutableArray new];
    }
    return _tasksList;
}

- (void)setDelegate:(id<DownloadManagerDelegate>)delegate{
    _delegate = delegate;
    if ([delegate respondsToSelector:@selector(downloadTaskStatusChanged:)]) {
        [delegate downloadTaskStatusChanged:self.tasksList];
    }
}

- (void)setTasksChangedBlock:(tasksStatusChanged)tasksChangedBlock{
    _tasksChangedBlock = tasksChangedBlock;
    if (tasksChangedBlock) {
        tasksChangedBlock(self.tasksList);
    }
}

- (void)applicationWillTerminate{
    [[CocoaDownloadSession sharedSession] suspendAllTasks];
}

- (void)applicationWillResignActive{
    [[CocoaDownloadSession sharedSession] suspendAllTasks];
}

- (void)applicationDidBecomeActive{
    [[CocoaDownloadSession sharedSession] startAllTasks];
}
@end

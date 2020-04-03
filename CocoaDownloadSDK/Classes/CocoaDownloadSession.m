//
//  CocoaDownloadSession.m
//  CocoaDownloadSDK
//
//  Created by 胡越 on 2020/3/25.
//

#import "CocoaDownloadSession.h"
#import "CocoaDownloadManager.h"

static CocoaDownloadSession *shared = nil;

@interface CocoaDownloadSession()<NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation CocoaDownloadSession

+ (instancetype)sharedSession{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (shared == nil) {
            shared = [[[self class] alloc] init];
        }
    });
    return shared;
}

- (instancetype)init {
    if (self = [super init]) {
        //初始化
        _session = [self getNewSession];
        _tasksList = [NSMutableArray new];
    }
    return self;
}

- (void)startTask:(CocoaDownloadTask *)task{
    if (!task || task.status == Completed) {
        return;
    }
    task.status = Running;
    NSURLSessionDownloadTask *downloadTask;
    NSData *resumeData = [task readResumedData];
    if (resumeData) {
        downloadTask = [self.session downloadTaskWithResumeData:resumeData];
    }
    else{
        NSURLRequest *request = [NSURLRequest requestWithURL:task.download_url];
        downloadTask = [self.session downloadTaskWithRequest:request];
        if (![_tasksList containsObject:task] && task != nil) {
            [_tasksList addObject:task];
        }
        if ([CocoaDownloadManager sharedInstance].tasksChangedBlock) {
            [CocoaDownloadManager sharedInstance].tasksChangedBlock(_tasksList);
        }
        
        if ([[CocoaDownloadManager sharedInstance].delegate respondsToSelector:@selector(downloadTaskStatusChanged:)]) {
            [[CocoaDownloadManager sharedInstance].delegate downloadTaskStatusChanged:_tasksList];
        }
        [self saveAllTasksStatus];
    }
    downloadTask.identifier = task.task_id;
    task.task = downloadTask;
    task.status = Running;
    [downloadTask resume];
    
    NSLog(@"开始下载任务%@：\nURL：%@\n地址：%@", task.task_id, task.download_url, [task getAbsoluteDownloadPath]);
}

- (void)suspendTask:(CocoaDownloadTask *)task{
    if (task.status != Running) {
        return;
    }
    task.status = Suspended;
    [task.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        task.status = Suspended;
        if ([task saveResumedData:resumeData]){
            NSLog(@"缓存成功");
        }
    }];
}

- (void)suspendAllTasks{
    NSLog(@"全部暂停");
    for (CocoaDownloadTask *task in _tasksList) {
        [self suspendTask:task];
    }
    [self saveAllTasksStatus];
}

- (void)saveAllTasksStatus{
    [NSKeyedArchiver archiveRootObject:_tasksList toFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"db/task.db"]];
}

- (NSURLSession *)getNewSession{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"CocoaDownloadSDK.SessionIdentifier"];
    sessionConfig.allowsCellularAccess = ![[NSUserDefaults standardUserDefaults]boolForKey:cDisableCellular];
    return [NSURLSession sessionWithConfiguration:sessionConfig
         delegate:self
    delegateQueue:[NSOperationQueue mainQueue]];
}

- (void)invalidAndRestartSession{
    __weak typeof(self) weakSelf = self;
    [_tasksList enumerateObjectsUsingBlock:^(CocoaDownloadTask *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf suspendTask:obj];
    }];
    [self.session invalidateAndCancel];
}

- (NSString *)getURLFromSessionTask:(NSURLSessionTask *)task {
    NSString *url = nil;
    url = [task originalRequest].URL.absoluteString;
    if(url.length == 0){
        url = [task currentRequest].URL.absoluteString;
    }
    return url;
}

- (int64_t)fileSizeWithPath:(NSString *)path {
    NSDictionary *dic = [fileManager attributesOfItemAtPath:path error:nil];
    return dic ? (int64_t)[dic fileSize] : 0;
}


- (CocoaDownloadTask *)getTaskFromURLSessionTask:(NSURLSessionTask *)session_task{
    NSString *downloadUrl = [self getURLFromSessionTask:session_task];
    __block CocoaDownloadTask *task;
    [_tasksList enumerateObjectsUsingBlock:^(CocoaDownloadTask *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj.download_url absoluteString] isEqualToString:downloadUrl] && [obj.task_id isEqualToString:session_task.identifier]) {
            task = obj;
            *stop = true;
        }
    }];
    return task;
}

#pragma - mark session delegate
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    _session = [self getNewSession];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    CocoaDownloadTask *task = [self getTaskFromURLSessionTask:downloadTask];
    task.fileSize = totalBytesExpectedToWrite;
    task.progress = (CGFloat)totalBytesWritten/totalBytesExpectedToWrite;
    if ([task.delegate respondsToSelector:@selector(downloadTask:downloadedSize:totalSize:)]) {
        [task.delegate downloadTask:task downloadedSize:totalBytesWritten totalSize:totalBytesExpectedToWrite];
    }
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    NSString *locationString = [location path];
    CocoaDownloadTask *task = [self getTaskFromURLSessionTask:downloadTask];
    if(!task){
        NSLog(@"%@", [NSString stringWithFormat:@"Download finish,but no task:%@",locationString]);
        return;
    }
    
    NSInteger fileSize = [self fileSizeWithPath:locationString];
    BOOL isCompltedFile = (fileSize > 0) && (fileSize == task.fileSize);
    if (!isCompltedFile) {
        task.status = Failed;
        [fileManager removeItemAtPath:locationString error:nil];
        NSLog(@"文件大小错误");
        return;
    }
    NSError *error;
    NSString *dir = [defaultDownloadDir stringByExpandingTildeInPath];
    if (![fileManager fileExistsAtPath:dir]) {
        [fileManager createDirectoryAtPath:dir withIntermediateDirectories:true attributes:nil error:&error];
        if (error) {
            task.status = Failed;
            NSLog(@"创建本地下载目录失败");
            NSLog(@"%@", error.localizedDescription);
            return;
        }
    }
    
    
    [fileManager moveItemAtPath:locationString toPath:[task getAbsoluteDownloadPath] error:&error];
    if (error) {
        task.status = Failed;
        [fileManager removeItemAtPath:locationString error:nil];
        NSLog(@"转存失败");
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    task.status = Completed;
    NSLog(@"%@下载完成",task.title);
    [self saveAllTasksStatus];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    //DownloadTask *task = [self getDownloadTaskFromUrl:downloadUrl];
}

#pragma - mark 懒加载
- (void)setTasksList:(NSMutableArray *)tasksList{
    _tasksList = tasksList;
    //搜索后台正在下载的任务
    NSMutableDictionary *dictTask = [_session valueForKey:@"tasks"];
    [dictTask enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSURLSessionDownloadTask *  _Nonnull obj, BOOL * _Nonnull stop) {
        CocoaDownloadTask *task = [self getTaskFromURLSessionTask:obj];
        if(!task){
            [obj cancel];
        }else{
            task.task = obj;
            task.status = Running;
        }
    }];
    [self saveAllTasksStatus];
}

@end

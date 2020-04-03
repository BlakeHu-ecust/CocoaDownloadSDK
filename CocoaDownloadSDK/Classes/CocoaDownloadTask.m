//
//  DownloadTask.m
//  CocoaDownloadSDK
//
//  Created by 胡越 on 2020/3/20.
//  Copyright © 2020 chinatelecom. All rights reserved.
//

#import "CocoaDownloadTask.h"
#import "CocoaDownloadManager.h"
#import "CocoaDownloadSession.h"
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"

//密钥
#define key            @"cocoadownload"
//偏移量
#define iv             @"0123456789"

@interface CocoaDownloadTask()
@end

@implementation CocoaDownloadTask

- (instancetype)initWithDownloadUrl:(NSURL *)url{
    return [self initWithDownloadUrl:url title:[url getLastPathComponent]];
}

- (instancetype)initWithDownloadUrl:(NSURL *)url title:(NSString *)title{
    self = [super init];
    if (self) {
        self.status = Waiting;
        self.download_url = url;
        self.localPath = defaultDownloadDir;
        _createDate = [NSDate date];
        self.title = title;
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.task_id forKey:@"task_id"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeInteger:self.status forKey:@"status"];
    [coder encodeObject:self.download_url forKey:@"download_url"];
    [coder encodeObject:self.localPath forKey:@"localPath"];
    [coder encodeInt64:self.fileSize forKey:@"fileSize"];
    [coder encodeObject:self.resumeData forKey:@"resumeData"];
    [coder encodeObject:self.createDate forKey:@"createDate"];
    [coder encodeFloat:self.progress forKey:@"progress"];
}

- (instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    if (self) {
        _task_id = [coder decodeObjectForKey:@"task_id"];
        _title = [coder decodeObjectForKey:@"title"];;
        _status = [coder decodeIntegerForKey:@"status"];
        _download_url= [coder decodeObjectForKey:@"download_url"];
        _localPath = [coder decodeObjectForKey:@"localPath"];
        _fileSize = [coder decodeInt64ForKey:@"fileSize"];
        _resumeData = [coder decodeObjectForKey:@"resumeData"];
        _createDate = [coder decodeObjectForKey:@"createDate"];
        _task = [coder decodeObjectForKey:@"task"];
        _progress = [coder decodeFloatForKey:@"progress"];
    }
    return self;
}

- (void)refreshCell{
    if (_statusChangedBlock) {
        _statusChangedBlock(self);
    }
}

- (void)startOrSuspend{
    if (_task != nil && _status == Running) {
        [[CocoaDownloadSession sharedSession]suspendTask:self];
    }
    else{
        [[CocoaDownloadSession sharedSession]startTask:self];
    }
}

- (void)setStatus:(DownloadTaskStatus)status{
    if (_status == status) {
        return;
    }
    _status = status;
    if (status == Completed || status == Failed) {
        [self cleanResumedData];
    }
    if ([self.delegate respondsToSelector:@selector(taskStatusChanged:)]) {
        [self.delegate taskStatusChanged:self];
    }
    [self refreshCell];
    [[CocoaDownloadSession sharedSession] saveAllTasksStatus];
}

- (void)setLocalPath:(NSString *)localPath{
    _localPath = localPath;
    [self refreshCell];
}

- (void)setTitle:(NSString *)title{
    _title = title;
    _task_id = [self encrypt:[NSString stringWithFormat:@"%@-%@-%@",[self.download_url absoluteString],title,_localPath]];
}
- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    [self refreshCell];
}

- (NSString *)getAbsoluteDownloadPath{
    return [[NSString stringWithFormat:@"%@%@", self.localPath, self.title] stringByExpandingTildeInPath];
}

- (BOOL)saveResumedData:(NSData *)data{
    NSString *cacheDocuments = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"download_tmp"];
    if (![[NSFileManager defaultManager]fileExistsAtPath:cacheDocuments]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDocuments withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *cacheName = [self.task_id substringFromIndex:[self.task_id length] - 24];
    cacheName = [cacheName stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *cachePath = [cacheDocuments stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",cacheName]];
    self.resumeData = [cachePath stringByAbbreviatingWithTildeInPath];
    return [data writeToURL:[NSURL fileURLWithPath:cachePath] atomically:YES];
}

- (NSData *)readResumedData{
    if ([self.resumeData length]) {
        return [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[self.resumeData stringByExpandingTildeInPath]]];
    }
    return nil;
}

- (void)cleanResumedData{
    if ([self.resumeData length] > 0) {
        NSError *error;
        [[NSFileManager defaultManager]removeItemAtPath:[self.resumeData stringByExpandingTildeInPath] error:&error];
        if (!error) {
            self.resumeData = @"";
        }
    }
}

- (void)remove{
    [[CocoaDownloadSession sharedSession]suspendTask:self];
    [self cleanResumedData];
    [fileManager removeItemAtPath:[self getAbsoluteDownloadPath] error:nil];
}

- (void)setStatusChangedBlock:(statusChanged)statusChangedBlock{
    _statusChangedBlock = statusChangedBlock;
    _statusChangedBlock(self);
}

#pragma mark - 加密方法
- (NSString*)encrypt:(NSString*)string {
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    size_t plainTextBufferSize = [data length];
    const void *vplainText = (const void *)[data bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *) [key UTF8String];
    const void *vinitVec = (const void *) [iv UTF8String];
    
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySize3DES,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    NSString *result = [GTMBase64 stringByEncodingData:myData];
    return result;
}

@end

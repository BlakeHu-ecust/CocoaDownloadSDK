//
//  CocoaDownloadConfig.h
//  CocoaDownloadSDK
//
//  Created by 胡越 on 2020/3/25.
//

#ifndef CocoaDownloadConfig_h
#define CocoaDownloadConfig_h

#define fileManager     [NSFileManager defaultManager]

#define documentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

//数据库存储地址
#define Db_Path   [documentPath stringByAppendingPathComponent:@"db"]

//下载模式
#define cDefaultDownloadMode @"defaultDownloadMode"
//下载路径
#define cDefaultDownloadPath @"defaultDownloadPath"
//蜂窝网配置
#define cDisableCellular  @"disableCellular"

//默认下载模式
#define defaultDownloadMode [[NSUserDefaults standardUserDefaults]integerForKey:cDefaultDownloadMode]

//默认下载地址
#define defaultDownloadDir [[[NSUserDefaults standardUserDefaults] objectForKey:cDefaultDownloadPath] length] > 0 ? [[NSUserDefaults standardUserDefaults] objectForKey:cDefaultDownloadPath] : @"~/Documents/Download/"

#endif /* CocoaDownloadConfig_h */

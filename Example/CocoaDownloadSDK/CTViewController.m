//
//  CTViewController.m
//  CocoaDownloadSDK
//
//  Created by 695081933@qq.com on 03/25/2020.
//  Copyright (c) 2020 695081933@qq.com. All rights reserved.
//

#import "CTViewController.h"
#import "CTTableViewCell.h"

@interface CTViewController ()<UITableViewDelegate, UITableViewDataSource, DownloadManagerDelegate, DownloadTaskDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray<CocoaDownloadTask *> *items;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSArray *assetURLs;
@end

@implementation CTViewController{
    CocoaDownloadTask *task;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"CTTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    _tableView.tableFooterView = [UIView new];
    [[CocoaDownloadManager sharedInstance] disableCellular];
    [[CocoaDownloadManager sharedInstance] setDefalutDownloadPath:@"Test"];

    //[CocoaDownloadManager sharedInstance].delegate = self;
    
    __weak typeof(self) weakSelf = self;
    [CocoaDownloadManager sharedInstance].tasksChangedBlock = ^(NSArray * _Nonnull tasks) {
        weakSelf.items = tasks;
        [weakSelf.tableView reloadData];
    };
}
- (IBAction)download:(id)sender {
    DownloadTaskError error;
    CocoaDownloadTask *task = [[CocoaDownloadManager sharedInstance] startTaskWithUrl:self.assetURLs[_currentIndex] config:DownloadTaskConfigCreate error:&error];
    if (!task && error) {
        switch (error) {
            case 1:
                NSLog(@"下载列表已有该任务");
                break;
            case 2:
                NSLog(@"下载地址无效");
                break;
            case 3:
                NSLog(@"存储地址无效");
                break;
            case 4:
                NSLog(@"空间不足");
                break;
            case 5:
                NSLog(@"当前无网络");
                break;
            case 6:
                NSLog(@"蜂窝网无法下载");
                break;
            default:
                break;
        }
    }
    else{
        _currentIndex += 1;
        if (_currentIndex >= self.assetURLs.count) {
            _currentIndex = 0;
        }
    }
    
    task.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CTTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.task = _items[indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [[CocoaDownloadManager sharedInstance]removeDownloadTask:_items[indexPath.row]];
    }];
    return @[deleteAction];
}
 
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    editingStyle = UITableViewCellEditingStyleDelete;
}

- (void)downloadTaskStatusChanged:(nonnull NSArray<CocoaDownloadTask *> *)tasks {
    self.items = tasks;
    [self.tableView reloadData];
}

- (NSArray *)items{
    if (!_items) {
        _items = [NSArray new];
    }
    return _items;
}

- (NSArray *)assetURLs{
    _assetURLs = @[
    [NSURL URLWithString:@"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"],
    [NSURL URLWithString:@"https://www.apple.com/105/media/cn/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/bruce/mac-bruce-tpl-cn-2018_1280x720h.mp4"],
    [NSURL URLWithString:@"https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/peter/mac-peter-tpl-cc-us-2018_1280x720h.mp4"],
    [NSURL URLWithString:@"https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/grimes/mac-grimes-tpl-cc-us-2018_1280x720h.mp4"],
    [NSURL URLWithString:@"http://flv3.bn.netease.com/tvmrepo/2018/6/H/9/EDJTRBEH9/SD/EDJTRBEH9-mobile.mp4"],
    [NSURL URLWithString:@"http://flv3.bn.netease.com/tvmrepo/2018/6/9/R/EDJTRAD9R/SD/EDJTRAD9R-mobile.mp4"],
    [NSURL URLWithString:@"http://www.flashls.org/playlists/test_001/stream_1000k_48k_640x360.m3u8"],
    [NSURL URLWithString:@"http://tb-video.bdstatic.com/tieba-video/7_517c8948b166655ad5cfb563cc7fbd8e.mp4"],
    [NSURL URLWithString:@"http://tb-video.bdstatic.com/tieba-smallvideo/68_20df3a646ab5357464cd819ea987763a.mp4"],
    [NSURL URLWithString:@"http://tb-video.bdstatic.com/tieba-smallvideo/118_570ed13707b2ccee1057099185b115bf.mp4"],
    [NSURL URLWithString:@"http://tb-video.bdstatic.com/tieba-smallvideo/15_ad895ac5fb21e5e7655556abee3775f8.mp4"],
    [NSURL URLWithString:@"http://tb-video.bdstatic.com/tieba-smallvideo/12_cc75b3fb04b8a23546d62e3f56619e85.mp4"],
    [NSURL URLWithString:@"http://tb-video.bdstatic.com/tieba-smallvideo/5_6d3243c354755b781f6cc80f60756ee5.mp4"],
                     [NSURL URLWithString:@"http://tb-video.bdstatic.com/tieba-movideo/11233547_ac127ce9e993877dce0eebceaa04d6c2_593d93a619b0.mp4"]];
    return _assetURLs;
}

- (void)downloadTask:(nonnull CocoaDownloadTask *)task downloadedSize:(int64_t)downloadedSize totalSize:(int64_t)totalSize {
    NSLog(@"%@ 状态：%.1f%%",task.title, task.progress * 100);
}

- (void)taskStatusChanged:(nonnull CocoaDownloadTask *)task {
    if (task.status == Completed) {
        NSLog(@"下载完成");
    }
}


@end

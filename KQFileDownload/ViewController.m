//
//  ViewController.m
//  KQFileDownload
//
//  Created by keqi on 16/6/13.
//  Copyright © 2016年 keqi. All rights reserved.
//

#import "ViewController.h"
#import "MMFileDownloadVO.h"
#import "KQDownloadTableViewCell.h"
#import "MMFileDownloadManager.h"

static NSString *kCellIdentifier = @"MMDownloadTableViewCell";

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *urls = @[@"http://farm6.staticflickr.com/5505/9824098016_0e28a047c2_b_d.jpg",
                      @"http://farm3.staticflickr.com/2846/9823925914_78cd653ac9_b_d.jpg",
                      @"http://farm3.staticflickr.com/2831/9823890176_82b4165653_b_d.jpg",
                      @"http://dl_dir.qq.com/qqfile/qq/QQforMac/QQ_V2.4.1.dmg",
                      @"http://download.xitongxz.com/Ylmf_Ghost_Win7_SP1_x64_2016_0512.iso"
                      ];
    
    for (int i = 0; i < urls.count; i++) {
        MMFileDownloadVO *model = [[MMFileDownloadVO alloc] init];
        NSString *url = urls[i];
        model.fileName = [NSString stringWithFormat:@"%d-%@",i,url.lastPathComponent];
        model.urlStr = url;
        //可省略(有默认路径)
        model.localPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"Download"] stringByAppendingPathComponent:[NSString stringWithFormat:@"haha%@",model.fileName]];
        
        [[MMFileDownloadManager sharedInstance] addTaskWithFileDownloadEntity:model];
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"KQDownloadTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[MMFileDownloadManager sharedInstance] getDownloadList].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KQDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier
                                                                    forIndexPath:indexPath];
    
    MMFileDownloadVO *model = [[MMFileDownloadManager sharedInstance] getDownloadList][indexPath.row];
    cell.model = model;
    
    model.onStatusChanged = ^(MMFileDownloadVO *changedModel) {
        cell.model = changedModel;
    };
    
    model.onProgressChanged = ^(MMFileDownloadVO *changedModel) {
        cell.model = changedModel;
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MMFileDownloadVO *model = [[MMFileDownloadManager sharedInstance] getDownloadList][indexPath.row];
    
    switch (model.status) {
        case kMMDownloadStatusNone: {
            [[MMFileDownloadManager sharedInstance] startWithFileDownloadEntity:model];
            break;
        }
        case kMMDownloadStatusRunning: {
            [[MMFileDownloadManager sharedInstance] suspendWithFileDownloadEntity:model];
            break;
        }
        case kMMDownloadStatusSuspended: {
            [[MMFileDownloadManager sharedInstance] resumeWithFileDownloadEntity:model];
            break;
        }
        case kMMDownloadStatusCompleted: {
            NSLog(@"已下载完成，路径：%@", model.localPath);
            break;
        }
        case kMMDownloadStatusFailed: {
            [[MMFileDownloadManager sharedInstance] resumeWithFileDownloadEntity:model];
            break;
        }
        case kMMDownloadStatusWaiting: {
            [[MMFileDownloadManager sharedInstance] startWithFileDownloadEntity:model];
            break;
        }
    }
}


@end

Date: 2016-06-14  
Title: Technical-training-exchange  
Published: true  
Type: post  
Excerpt:   

# Technical-training-exchange
# KQFileDownload

- ###功能介绍：
   基于NSURLSession的多线程下载管理功能模块，自定义了NSOperation用于专门做下载，用NSOperationQueue去管理多个下载任务。具体有如下特色：

	* 封装完善，可直接拿来使用，导入KQFileDownload文件夹下内容即可；  
	* 支持并发下载，而且可设置最大线程数； 
 	* 支持开始，暂停，继续，删除某个下载任务； 
	* 支持断点续传（出现异常或者退出应用后数据库会保存当前下载进度）；
 	* 可获取当前下载列表。


- #### 效果图如下：

![image](https://github.com/keqi90/KQFileDownload/blob/master/fileDownload.gif )   

- ### 使用方法：

  * 添加数据源
  
	 ```
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

	 ```
	 
  * 更新下载进度
  
    ```
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
    ```
	 
  * 界面交互，展示下载状态
  
	```
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
	```
  


作者说：如有问题请email：keqi90@163.com [@KeQi的简书主页](http://www.jianshu.com/users/e785cd3b553e/latest_articles)。

2016年6月14日 下午3:22
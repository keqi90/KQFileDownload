//
//  MMFileDownloadVO.m
//  MMFileDownload
//
//  Created by keqi on 16/5/26.
//  Copyright © 2016年 keqi. All rights reserved.
//

#import "MMFileDownloadVO.h"

@implementation MMFileDownloadVO

- (void)setProgress:(float)progress {
    if (_progress != progress) {
        _progress = progress;
        
        if (self.onProgressChanged) {
            self.onProgressChanged(self);
        } else {
            NSLog(@"progress changed block is empty");
        }
    }
}

- (void)setStatus:(MMDownloadStatus)status {
    if (_status != status) {
        _status = status;
        
        if (self.onStatusChanged) {
            self.onStatusChanged(self);
        }
    }
}

- (NSString *)statusText {
    switch (self.status) {
        case kMMDownloadStatusNone: {
            return @"";
            break;
        }
        case kMMDownloadStatusRunning: {
            return @"下载中";
            break;
        }
        case kMMDownloadStatusSuspended: {
            return @"暂停下载";
            break;
        }
        case kMMDownloadStatusCompleted: {
            return @"下载完成";
            break;
        }
        case kMMDownloadStatusFailed: {
            return @"下载失败";
            break;
        }
        case kMMDownloadStatusWaiting: {
            return @"等待下载";
            break;
        }
    }
}

@end

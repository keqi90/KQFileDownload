//
//  MMFileDownloadVO.h
//  StaticFrameworkTest
//
//  Created by keqi on 16/5/26.
//  Copyright © 2016年 keqi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMFileDownloadOperation, MMFileDownloadVO;

typedef NS_ENUM(NSInteger, MMDownloadStatus) {
    kMMDownloadStatusNone = 0,       // 初始状态
    kMMDownloadStatusRunning = 1,    // 下载中
    kMMDownloadStatusSuspended = 2,  // 下载暂停
    kMMDownloadStatusCompleted = 3,  // 下载完成
    kMMDownloadStatusFailed  = 4,    // 下载失败
    kMMDownloadStatusWaiting = 5    // 等待下载
};

typedef void(^MMDownloadStatusChanged)(MMFileDownloadVO *model);
typedef void(^MMDownloadProgressChanged)(MMFileDownloadVO *model);

@interface MMFileDownloadVO : NSObject

/**
 *  下载记录ID
 */
@property (nonatomic, assign) long ID;
/**
 *  下载文件名
 */
@property (nonatomic, copy) NSString *fileName;
/**
 *  下载地址
 */
@property (nonatomic, copy) NSString *urlStr;
/**
 *  已下载的大小
 */
@property (nonatomic, assign) int64_t downloadedSize;
/**
 *  文件总大小
 */
@property (nonatomic, assign) int64_t totalSize;
/**
 *  文件保存绝对路径（含文件名，由调用方保证文件名不会冲突），如果传nil，则采用默认
 */
@property (nonatomic, copy) NSString *localPath;
/**
 *  文件下载状态
 */
@property (nonatomic, assign) MMDownloadStatus status;
/**
 *  下载状态描述
 */
@property (nonatomic, copy) NSString *statusText;
/**
 *  子类化的NSOperation，用于专门做下载
 */
@property (nonatomic, strong) MMFileDownloadOperation *operation;

/**
 *  下载进度
 */
@property (nonatomic, assign) float progress;

/**
 *  下载状态变化的回调
 */
@property (nonatomic, copy) MMDownloadStatusChanged onStatusChanged;
/**
 *  下载进度变化的回调
 */
@property (nonatomic, copy) MMDownloadProgressChanged onProgressChanged;
@end

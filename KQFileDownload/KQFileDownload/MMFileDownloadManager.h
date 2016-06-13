//
//  MMFileDownloadManager.h
//  MMUtils
//
//  Created by keqi on 16/5/25.
//  Copyright © 2016年 keqi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMFileDownloadVO;
@interface MMFileDownloadManager : NSObject

/**
 *  获取文件下载管理器对象
 */
+ (id)sharedInstance;

/**
 *  初始化文件下载管理器
 *
 *  @param threadNum   最大线程数(可同时下载的最大文件数)，取值[1-5]，超出取默认值3
 */
- (void)initWithMaxThreadNum:(int)threadNum;

/**
 *  添加一个下载任务，不启动
 *
 *  @param model 文件下载对象的数据信息对象
 */
- (void)addTaskWithFileDownloadEntity:(MMFileDownloadVO *)model;

/**
 *  开始下载
 */
- (void)startWithFileDownloadEntity:(MMFileDownloadVO *)model;

/**
 *  暂停下载
 */
- (void)suspendWithFileDownloadEntity:(MMFileDownloadVO *)model;

/**
 *  继续下载
 */
- (void)resumeWithFileDownloadEntity:(MMFileDownloadVO *)model;

/**
 *  停止下载
 */
- (void)stopWithFileDownloadEntity:(MMFileDownloadVO *)model;

/**
 *  根据下载任务标识获取文件下载对象的数据信息对象
 *
 *  @param ID 下载记录ID
 *
 *  @return 文件下载对象的数据信息对象
 */
- (MMFileDownloadVO *)getFileDownloadEntity:(long)ID;

/**
 *  根据下载地址获取文件下载对象的数据信息对象
 *
 *  @param urlStr 下载地址
 *
 *  @return 文件下载对象的数据信息对象
 */
- (MMFileDownloadVO *)getFileDownloadEntityByUrl:(NSString *)urlStr;

/**
 *  获取所有的下载数据清单
 *
 *  @return 下载列表
 */
- (NSArray<MMFileDownloadVO *> *)getDownloadList;
@end

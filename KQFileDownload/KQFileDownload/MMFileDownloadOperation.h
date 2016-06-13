//
//  MMFileDownloadOperation.h
//  MMFileDownload
//
//  Created by keqi on 16/6/6.
//  Copyright © 2016年 keqi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMFileDownloadVO;
@interface MMFileDownloadOperation : NSOperation

@property (nonatomic, strong) MMFileDownloadVO *model;

/**
 *  创建下载工具对象
 */
- (instancetype)initWithModel:(MMFileDownloadVO *)model;
/**
 *  暂停下载
 */
- (void)suspendDownload;
/**
 *  继续下载
 */
- (void)resumeDownload;
@end

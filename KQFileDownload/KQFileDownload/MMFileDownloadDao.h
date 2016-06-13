//
//  MMFileDownloadDao.h
//  StaticFrameworkTest
//
//  Created by keqi on 16/5/26.
//  Copyright © 2016年 keqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMFileDownloadDBUtil.h"

@interface MMFileDownloadDao : NSObject
{
    FMDatabaseQueue *_dbQueue;
}

/**
 * 根据下载记录ID查询
 */
- (id)queryWithID:(long)ID;

/**
 *  根据下载地址查询
 */
- (id)queryWithURL:(NSString *)urlStr;

/**
 * 新增
 */
- (BOOL)insertWithEntity:(NSObject *)entity;

/**
 *  修改
 */
- (BOOL)updateWithEntity:(NSObject *)entity;

- (BOOL)updateWithID:(NSObject *)entity;

/**
 * 删除
 */
- (BOOL)deleteWithEntity:(NSObject *)entity;
@end

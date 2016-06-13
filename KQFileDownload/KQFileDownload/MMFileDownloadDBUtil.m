//
//  MMFileDownloadDBUtil.m
//  MMFileDownload
//
//  Created by keqi on 16/5/26.
//  Copyright © 2016年 keqi. All rights reserved.
//

#import "MMFileDownloadDBUtil.h"
#import "MMFileDownloadDBConstants.h"

static NSString *DATABASE_NAME = @"MMFileDownload.db";

@implementation MMFileDownloadDBUtil

+ (FMDatabaseQueue *)getDBQueue {
   
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:DATABASE_NAME];
    NSLog(@"dbPath: %@", dbPath);
    
    FMDatabaseQueue *dbQueue = nil;
    dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        if ([db open]) {
            [db setShouldCacheStatements:YES];
            NSLog(@"Open success %@ !", DATABASE_NAME);
        } else {
            NSLog(@"Failed to open %@ !", DATABASE_NAME);
        }
        
        //如果需要建表
        if (![db tableExists:[MMFileDownloadDBConstants tableName]]) {
            [db executeUpdate:[MMFileDownloadDBConstants getCreateSQL]] ? CFShow(@"create table succes") : CFShow(@"create table fail");
        }
    }];

    return dbQueue;
}
@end

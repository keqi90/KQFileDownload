//
//  MMFileDownloadDao.m
//  StaticFrameworkTest
//
//  Created by keqi on 16/5/26.
//  Copyright © 2016年 keqi. All rights reserved.
//

#import "MMFileDownloadDao.h"
#import "MMFileDownloadDBConstants.h"
#import "MMFileDownloadVO.h"

@implementation MMFileDownloadDao

- (instancetype)init {
    if (self = [super init]) {
        _dbQueue = [MMFileDownloadDBUtil getDBQueue];
    }
    return self;
}

- (void)dealloc {
    
    if (_dbQueue == nil) {return;}
    else { [_dbQueue close]; _dbQueue = nil; }
}

- (BOOL)insertWithEntity:(NSObject *)entity {
    
    MMFileDownloadVO *vo = (MMFileDownloadVO *)entity;
    
    __block BOOL success = YES;

    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[MMFileDownloadDBConstants getInsertSQL], vo.fileName, vo.urlStr, @(vo.downloadedSize), @(vo.totalSize), vo.localPath, @(vo.status)];
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            success = NO;
        }
    }];
    
    return success;
}

- (BOOL)updateWithEntity:(NSObject *)entity {
    
    MMFileDownloadVO *vo = (MMFileDownloadVO *)entity;
    
    __block BOOL success = YES;
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[MMFileDownloadDBConstants getAlterSQL], vo.fileName, vo.urlStr, @(vo.downloadedSize), @(vo.totalSize), vo.localPath, @(vo.status)];
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            success = NO;
        }
    }];
    return success;
}

- (BOOL)updateWithID:(NSObject *)entity {
    
    MMFileDownloadVO *vo = (MMFileDownloadVO *)entity;

    __block BOOL success = YES;
    
    [_dbQueue inDatabase:^(FMDatabase *db) {

        [db executeUpdate:[MMFileDownloadDBConstants getAlterSQL], vo.fileName, vo.urlStr, @(vo.downloadedSize), @(vo.totalSize), vo.localPath, @(vo.status),@(vo.ID)];
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            success = NO;
        }
    }];
    return success;
}

- (id)queryWithID:(long)ID {
    
    __block MMFileDownloadVO *vo = nil;

    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[MMFileDownloadDBConstants getQuerySQLV2], @(ID)];
        
        if ([rs next]) {
            vo = [[MMFileDownloadVO alloc]  init];
            vo.ID = [rs intForColumn:@"ID"];
            vo.fileName = [rs stringForColumn:@"fileName"];
            vo.urlStr = [rs stringForColumn:@"urlStr"];
            vo.downloadedSize = [rs longLongIntForColumn:@"downloadedSize"];
            vo.totalSize = [rs longLongIntForColumn:@"totalSize"];
            vo.localPath = [rs stringForColumn:@"localPath"];
            vo.status = [rs intForColumn:@"status"];
        }
        [rs close];
    }];
    
    return vo;
}

- (id)queryWithURL:(NSString *)urlStr {
    
    __block MMFileDownloadVO *vo = nil;

    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[MMFileDownloadDBConstants getQuerySQL], urlStr];
        
        if ([rs next]) {
            vo = [[MMFileDownloadVO alloc]  init];
            vo.ID = [rs intForColumn:@"ID"];
            vo.fileName = [rs stringForColumn:@"fileName"];
            vo.urlStr = [rs stringForColumn:@"urlStr"];
            vo.downloadedSize = [rs longLongIntForColumn:@"downloadedSize"];
            vo.totalSize = [rs longLongIntForColumn:@"totalSize"];
            vo.localPath = [rs stringForColumn:@"localPath"];
            vo.status = [rs intForColumn:@"status"];
        }
        [rs close];
    }];
    return vo;
}

- (BOOL)deleteWithEntity:(NSObject *)entity {
    MMFileDownloadVO *vo = (MMFileDownloadVO *)entity;
    
    __block  BOOL success = YES;
    
    [_dbQueue inDatabase:^(FMDatabase *db) {

        if (vo) {
            
            [db executeUpdate:[MMFileDownloadDBConstants getDeleteSQL], [NSNumber numberWithLong:vo.ID]];
        }
        else {
            
            [db executeUpdate:[MMFileDownloadDBConstants getDeleteAllSQL]];
        }
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            success = NO;
        }
    }];

    return success;
}
@end

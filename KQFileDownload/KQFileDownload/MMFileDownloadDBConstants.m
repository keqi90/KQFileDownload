//
//  MMFileDownloadDBConstants.m
//  MMFileDownload
//
//  Created by keqi on 16/5/26.
//  Copyright © 2016年 keqi. All rights reserved.
//

#import "MMFileDownloadDBConstants.h"


@implementation MMFileDownloadDBConstants

NSString *const TABLE_FILEINFO = @"FileInfo";

NSString *const fileID = @"ID";
NSString *const fileName = @"fileName";
NSString *const urlStr = @"urlStr";
NSString *const downloadedSize = @"downloadedSize";
NSString *const totalSize = @"totalSize";
NSString *const localPath = @"localPath";
NSString *const status = @"status";


+ (NSString *)tableName { return TABLE_FILEINFO; }

+ (NSString *)getCreateSQL {
    return [NSString stringWithFormat:
            @"CREATE TABLE IF NOT EXISTS "
            "%@"
            " (%@ INTEGER PRIMARY KEY AUTOINCREMENT , "
            "%@"
            " TEXT , "
            "%@"
            " TEXT , "
            "%@"
            " INTEGER , "
            "%@"
            " INTEGER , "
            "%@"
            " TEXT , "
            "%@"
            " INTEGER )",
            TABLE_FILEINFO,
            fileID,
            fileName,
            urlStr,
            downloadedSize,
            totalSize,
            localPath,
            status];
}

+ (NSString *)getQuerySQL {
    return [NSString stringWithFormat:
            @"select * from %@ where "
            "%@ = ?",
            TABLE_FILEINFO,
            urlStr];
}

+ (NSString *)getQuerySQLV2 {
    return [NSString stringWithFormat:
            @"select * from %@ where "
            "%@ = ?",
            TABLE_FILEINFO,
            fileID];
}

+ (NSString *)getQuerySQLV3 {
    return [NSString stringWithFormat:
            @"select * from %@",
            TABLE_FILEINFO];
}


+ (NSString *)getInsertSQL {
    return [NSString stringWithFormat:
            @"INSERT INTO %@(%@, %@, %@, %@, %@, %@) "
            "VALUES (?,?,?,?,?,?)",
            TABLE_FILEINFO,
            fileName, urlStr, downloadedSize, totalSize, localPath, status];
}

+ (NSString *)getAlterSQL {
    return [NSString stringWithFormat:
            @"UPDATE %@ SET %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ? WHERE %@ = ?",
            TABLE_FILEINFO,
            fileName, urlStr, downloadedSize, totalSize, localPath, status, fileID];
}

+ (NSString *)getDeleteSQL {
    return [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",TABLE_FILEINFO, fileID];
}

+ (NSString *)getDeleteAllSQL {
    return [NSString stringWithFormat:@"DELETE FROM %@",TABLE_FILEINFO];
}
@end

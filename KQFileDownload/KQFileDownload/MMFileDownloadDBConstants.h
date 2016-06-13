//
//  MMFileDownloadDBConstants.h
//  StaticFrameworkTest
//
//  Created by keqi on 16/5/26.
//  Copyright © 2016年 keqi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMFileDownloadDBConstants : NSObject

+ (NSString *)tableName;

+ (NSString *)getCreateSQL;

+ (NSString *)getInsertSQL;

+ (NSString *)getAlterSQL;

+ (NSString *)getDeleteSQL;

+ (NSString *)getDeleteAllSQL;

+ (NSString *)getQuerySQL;

+ (NSString *)getQuerySQLV2;
@end
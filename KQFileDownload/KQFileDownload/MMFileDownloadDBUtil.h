//
//  MMFileDownloadDBUtil.h
//  MMFileDownload
//
//  Created by keqi on 16/5/26.
//  Copyright © 2016年 keqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface MMFileDownloadDBUtil : NSObject

+ (FMDatabaseQueue *)getDBQueue;
@end

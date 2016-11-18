//
//  MMFileDownloadManager.m
//  MMFileDownload
//
//  Created by keqi on 16/5/25.
//  Copyright © 2016年 keqi. All rights reserved.
//

#import "MMFileDownloadManager.h"
#import "MMFileDownloadVO.h"
#import "MMFileDownloadDao.h"
#import "MMFileDownloadOperation.h"
#import <UIKit/UIKit.h>

#define DEFAULT_SAVE_DIRECTORY [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MMFileDownload"]

@interface MMFileDownloadManager ()
{
    //存放下载任务列表
    NSMutableArray<MMFileDownloadVO *> *_fileDownloadModels;
}

//下载队列
@property (nonatomic, strong) NSOperationQueue *operationQueue;

//数据库
@property (nonatomic, strong) MMFileDownloadDao *dao;
@end

@implementation MMFileDownloadManager

static MMFileDownloadManager *_instance = nil;
+ (id)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MMFileDownloadManager alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
            return _instance;
        }
    }
    return nil;
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return self;
}

- (id)init {
    if (self = [super init]) {
        _fileDownloadModels = [[NSMutableArray alloc] init];
        
        //添加应用程序退出的通知
        [self addNotification];
        
        //查询已经存储的下载对象
        NSArray *voList = [self.dao queryAll];
        if (voList.count) {
            [_fileDownloadModels addObjectsFromArray:voList];
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminateNotification)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

- (void)setMaxThreadNum:(int)threadNum {
    if ( threadNum < 1 || threadNum > 5) {
        threadNum = 3;
    }
    self.operationQueue.maxConcurrentOperationCount = threadNum;
}

/**
 *  创建存放路径
 */
- (void)createSaveDirectory:(NSString *)dir {
    
    //默认路径
    if (!dir || [dir isKindOfClass:[NSNull class]]) {
        dir = DEFAULT_SAVE_DIRECTORY;
    }
    NSLog(@"saveDir: %@", dir);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dir]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:dir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
        if (error) {
            NSLog(@"Create Dir Error: %@", error);
        }
    }
}

#pragma mark - event response

- (NSArray<MMFileDownloadVO *> *)getDownloadList {
    return _fileDownloadModels;
}

- (void)addTaskWithFileDownloadEntity:(MMFileDownloadVO *)model {
    
    if (model) {
        
        MMFileDownloadVO *dbVO = [self.dao queryWithURL:model.urlStr];
        if (dbVO == nil) {// 如果数据库里没有记录，存入数据库
            
            //拼接文件路径
            if (!model.localPath) {
                //创建默认存储路径
                [self createSaveDirectory:DEFAULT_SAVE_DIRECTORY];
                model.localPath = [DEFAULT_SAVE_DIRECTORY stringByAppendingPathComponent:model.fileName];
            } else {
                NSString *saveDir = [model.localPath stringByDeletingLastPathComponent];
                [self createSaveDirectory:saveDir];
            }
            
            //存入数据库
            [self.dao insertWithEntity:model];
            dbVO = [self.dao queryWithURL:model.urlStr];
            model.ID = dbVO.ID;   //赋值ID
            [_fileDownloadModels addObject:model];
        }
    }
}

- (void)startWithFileDownloadEntity:(MMFileDownloadVO *)model {
    if (model.status != kMMDownloadStatusCompleted) {
        model.status = kMMDownloadStatusRunning;
        
        if (model.operation == nil) {
            model.operation = [[MMFileDownloadOperation alloc] initWithModel:model];
            [self.operationQueue addOperation:model.operation];
        } else {
            [model.operation resumeDownload];
        }
    }
}

- (void)suspendWithFileDownloadEntity:(MMFileDownloadVO *)model {
    if (model.status != kMMDownloadStatusCompleted) {
        [model.operation suspendDownload];
    }
}

- (void)resumeWithFileDownloadEntity:(MMFileDownloadVO *)model {
    if (model.status != kMMDownloadStatusCompleted) {
        
        if (model.operation == nil) {
            model.operation = [[MMFileDownloadOperation alloc] initWithModel:model];
            [model.operation resumeDownload];

        } else {
            [model.operation resumeDownload];
        }
    }
}

- (void)stopWithFileDownloadEntity:(MMFileDownloadVO *)model {
    if (model.operation) {
        
        [model.operation cancel];
        
        //数据库删除该任务
        [self.dao deleteWithEntity:model];
    }
}

- (MMFileDownloadVO *)getFileDownloadEntity:(long)ID {
    
    //从数据库取对应的任务
    MMFileDownloadVO *vo = [self.dao queryWithID:ID];
    
    return vo;
}

- (MMFileDownloadVO *)getFileDownloadEntityByUrl:(NSString *)urlStr {
    
    //从数据库取对应的任务
    MMFileDownloadVO *vo = [self.dao queryWithURL:urlStr];

    return vo;
}

//应用程序退出 保存状态
- (void)appWillTerminateNotification {
    NSLog(@"applicationWillTerminate");

    for (MMFileDownloadVO *vo in _fileDownloadModels) {
        if (vo.status == kMMDownloadStatusRunning) {
            vo.status = kMMDownloadStatusSuspended;
            [self.dao updateWithID:vo];
        }
    }
}

#pragma mark - Lazy Loading

/**
 *  设置默认最大进程数为3
 */
- (NSOperationQueue *)operationQueue {
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 3;
    }
    return _operationQueue;
}

- (MMFileDownloadDao *)dao {
    if (!_dao) {
        _dao = [[MMFileDownloadDao alloc] init];
    }
    return _dao;
}
@end

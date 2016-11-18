//
//  MMFileDownloadOperation.m
//  MMFileDownload
//
//  Created by keqi on 16/6/6.
//  Copyright © 2016年 keqi. All rights reserved.
//

#import "MMFileDownloadOperation.h"
#import "MMFileDownloadVO.h"
#import "MMFileDownloadDao.h"

@interface MMFileDownloadOperation ()<NSURLSessionDataDelegate> {
    BOOL _executing;
    BOOL _finished;
}
/** 数据库 */
@property (nonatomic, strong) MMFileDownloadDao *dao;
/** Session会话 */
@property (nonatomic, strong) NSURLSession *session;
/** Task任务 */
@property (nonatomic, strong) NSURLSessionDataTask *task;
/** 文件的全路径 */
@property (nonatomic, strong) NSString *fileFullPath;
/** 当前已经下载的文件的长度 */
@property (nonatomic, assign) NSInteger currentFileSize;
/** 输出流 */
@property (nonatomic, strong) NSOutputStream *outputStream;

@end
@implementation MMFileDownloadOperation

- (instancetype)initWithModel:(MMFileDownloadVO *)model {
    if (self = [super init]) {
        self.model = model;  //很关键
        //创建下载任务
        [self creatDownloadSessionTaskWithURLString:model.urlStr];
    }
    return self;
}


#pragma mark - Create Session And Task
- (void)creatDownloadSessionTaskWithURLString:(NSString *)urlString {
    
    //赋值全路径
    self.fileFullPath = self.model.localPath;
    NSLog(@"fullPath:%@", self.fileFullPath);
    
    //获取文件已经下载的长度，断点续传需要此参数
    self.currentFileSize = self.model.downloadedSize;
    
    //判断文件是否已经下载完毕
    if (self.currentFileSize == self.model.totalSize && self.currentFileSize != 0) {
        NSLog(@"文件已经下载完毕");
        return;
    }
    //创建会话
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:self
                             delegateQueue:[[NSOperationQueue alloc]init]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    //设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",self.currentFileSize];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    //创建任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    self.session = session;
    self.task = task;
}

#pragma mark - Operate The Download State
// 暂停下载
- (void)suspendDownload {
    
    NSLog(@"suspendDownload - %@",self.task);
    
    if (self.task) {
        
        [self willChangeValueForKey:@"isExecuting"];
        _executing = NO;
        [self didChangeValueForKey:@"isExecuting"];
        self.model.status = kMMDownloadStatusSuspended;
        
        [self.task suspend];
    }
    //保存当前下载进度
    [self.dao updateWithID:self.model];
}

- (void)resumeDownload {
    
    NSLog(@"resumeDownload");
    
    if (self.model.status == kMMDownloadStatusCompleted) {
        return;
    }
    self.model.status = kMMDownloadStatusRunning;
    
    [self willChangeValueForKey:@"isExecuting"];
    [self.task resume];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
}

#pragma mark - NSURLSessionDataDelegate
// 收到响应调用的代理方法
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSLog(@"didReceiveResponse");
    // 创建输出流，并打开流
    if (self.fileFullPath) {
        
        NSOutputStream *outputStream = [[NSOutputStream alloc] initToFileAtPath:self.fileFullPath append:YES];
        [outputStream open];
        self.outputStream = outputStream;
    }
    
    // 如果当前已经下载的文件长度等于0，那么就需要将总长度信息存入数据库
    if (self.currentFileSize == 0) {
        
        // 别忘了设置总长度
        self.model.totalSize = response.expectedContentLength;
        [self.dao updateWithID:self.model];
    }
    //允许收到响应
    completionHandler(NSURLSessionResponseAllow);
}

// 收到数据调用的代理方法
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    // 通过输出流写入数据
    [self.outputStream write:data.bytes maxLength:data.length];
    
    // 将写入的数据的长度计算加进当前的已经下载的数据长度
    self.currentFileSize += data.length;
    
    self.model.downloadedSize = self.currentFileSize;
    NSLog(@"didReceiveData: %lf - %lf",self.currentFileSize * 1.0,self.model.totalSize * 1.0);
    
    // 设置进度值
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.model.totalSize != 0) {
            self.model.progress = self.currentFileSize * 1.0 / self.model.totalSize;
        }
    });
}

// 数据下载完成调用的方法
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{

        if (error == nil) {
            self.model.status = kMMDownloadStatusCompleted;
            [self completeOperation];
        }
        else if (self.model.status == kMMDownloadStatusSuspended) {
            self.model.status = kMMDownloadStatusSuspended;
        }
        else if ([error code] < 0) {
            // 网络异常
            self.model.status = kMMDownloadStatusFailed;
            NSLog(@"下载完成：%@",error);
        }
    });
    
    //更新下载状态
    [self.dao updateWithID:self.model];
    
    // 关闭输出流 并关闭强指针
    [self.outputStream close];
    self.outputStream = nil;
    // 关闭会话
    [self.session invalidateAndCancel];
}

#pragma mark - Overwrite Methods
- (void)start {
    
    NSLog(@"start==========");
    // 如果我们取消了在开始之前，我们就立即返回并生成所需的KVO通知
    if ([self isCancelled]){
        // 我们取消了该 operation，那么就要告诉KVO，该operation还未执行完成（isFinished == NO）
        // 这样，调用的队列（或者线程）会继续执行。
        [self willChangeValueForKey:@"isFinished"];
        _finished = NO;
        [self didChangeValueForKey:@"isFinished"];
    } else {
        // 没有取消，那就要告诉KVO，该队列开始执行了（isExecuting）！那么，就会调用main方法，进行同步执行。
        [self willChangeValueForKey:@"isExecuting"];
        _executing = YES;
        
        [self.task resume];
        self.model.status = kMMDownloadStatusRunning;
        //        [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (void)main {
    NSLog(@"main==========");
    
    // 新建一个自动释放池，如果是异步执行操作，那么将无法访问到主线程的自动释放池
    @autoreleasepool {
        
        if (self.isCancelled) {
            return;
        }
    }
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_7_0
- (BOOL)isConcurrent {
    return YES;
}

#else

- (BOOL)isAsynchronous {
    return YES;
}
#endif


- (void)cancel {
    [self willChangeValueForKey:@"isCancelled"];
    [super cancel];
    [self.task cancel];
    self.task = nil;
    [self didChangeValueForKey:@"isCancelled"];
    [self completeOperation];
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    _executing = NO;
    _finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - Lazy loading
- (MMFileDownloadDao *)dao {
    if (!_dao) {
        _dao = [[MMFileDownloadDao alloc] init];
    }
    return _dao;
}
@end

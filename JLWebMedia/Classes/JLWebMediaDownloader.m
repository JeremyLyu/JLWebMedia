//
//  JLWebMediaDownloader.m
//  JLWebMedia
//
//  Created by JeremyLyu_PinGuo on 15/6/10.
//  Copyright (c) 2015年 JeremyLyu. All rights reserved.
//

#import "JLWebMediaDownloader.h"
#import <UIKit/UIKit.h>
#import "JLWebMediaCompat.h"
#import "JLWebMediaControl.h"

@implementation NSURLSessionDownloadTask (JLWebMedia)

@end

@interface NSURLSessionConfiguration (JLWebMedia)
+ (NSURLSessionConfiguration *)jl_BackgroundSessionConfiguration:(NSString *)identifier;
@end

@implementation NSURLSessionConfiguration (JLWebMedia)
+ (NSURLSessionConfiguration *)jl_BackgroundSessionConfiguration:(NSString *)identifier
{
    if([[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)
    {
       return [NSURLSessionConfiguration backgroundSessionConfiguration:identifier];
    }
    else
    {
        return [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    }
}

@end

#import "JLWebMediaDownloader+sessionDelegate.h"

@interface JLWebMediaDownloader ()
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary *URLCallbacksDict;
//一个并发队列控制对URLCallbacks字典的多线程访问
@property (nonatomic, strong) dispatch_queue_t barrierQueue;
@end

@implementation JLWebMediaDownloader

+ (JLWebMediaDownloader *)shareDownloader
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (void)dealloc
{
    //TODO: 一些必要清理操作
    [self.session invalidateAndCancel];
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.URLCallbacksDict = [NSMutableDictionary new];
        self.barrierQueue = dispatch_queue_create("cn.jeremy.JLWebMediaDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        
        [self configurateSession];
    }
    return self;
}

//配置网络会话
- (void)configurateSession
{
    //configuration设置
    NSString *identifier = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@"_JLWebMediaDownloader"];
    NSURLSessionConfiguration *sesionConfig = [NSURLSessionConfiguration jl_BackgroundSessionConfiguration:identifier];
    //TODO: 网络超时,自定义
    sesionConfig.timeoutIntervalForRequest = 15;
    //设置session
    self.session = [NSURLSession sessionWithConfiguration:sesionConfig delegate:self delegateQueue:nil];
    //TODO: 独立的delegateQueue，并且允许并发回调。以增加效率
}

//重置方法
//TODO: 重置方法，尽可能的释放资源
- (void)reset
{
    
}

- (id<JLWebMediaOperation>)downloadFileWithURL:(NSURL *)url
             progress:(JLWebMediaDownloaderProgressBlock)progressBlock
        comletedBlock:(JLWebMediaDownloaderCompletedBlock)completedBlock
{
    __block NSURLSessionDownloadTask *downloadTask;
    __weak typeof(self) weakSelf = self;
    
    [self addProgressCallback:progressBlock completedBlock:completedBlock forURL:url createCallback:^{
        //查找下载resumeData路径，看看是否有没有完成的数据，如果有则利用数据，进行断点续传
        NSString *resumeDataPath = [weakSelf resumeDataPathWithURL:url];
        //TODO: 考虑断点续载的过期时间处理
        //TODO: 应用关闭后，冷启动，断点下载有问题
        if([[JLWebMediaControl share] fileExistWithPath:resumeDataPath])
        {
            NSData *resumeData = [[NSData alloc] initWithContentsOfFile:resumeDataPath];
            downloadTask = [weakSelf.session downloadTaskWithResumeData:resumeData];
            //清除断点内容缓存
            [[JLWebMediaControl share] removeItemForPath:resumeDataPath completion:^{
                NSLog(@"JLWebMediaDownloader:清除了断点缓存信息内容");
            }];
        }
        //否则创建一个全新的下载
        else
        {
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            downloadTask = [weakSelf.session downloadTaskWithRequest:request];
        }
        [downloadTask resume];
    }];
    return downloadTask;
}

#pragma mark - 对外回调字典操作
//向对外回调字典添加回调
- (void)addProgressCallback:(JLWebMediaDownloaderProgressBlock)progressBlock
             completedBlock:(JLWebMediaDownloaderCompletedBlock)completedBlock
                     forURL:(NSURL *)url
             createCallback:(JLWebMediaNoParamsBlock)createCallback
{
    //URL是Callbaks的key,不能为Nil.否则，直接告诉外部下载无法完成
    if(url == nil)
    {
        if(completedBlock) completedBlock(nil, nil, NO);
        return ;
    }
    //使用同步的方式，因为需要在对应createCallback中,完成对task的初始化，并返还给外部
    dispatch_barrier_sync(self.barrierQueue, ^{
        BOOL isCreated = NO;
        if(!self.URLCallbacksDict[url])
        {
            self.URLCallbacksDict[url] = [NSMutableArray new];
            isCreated = YES;
        }
        NSMutableArray *callbacks = self.URLCallbacksDict[url];
        NSMutableDictionary *callback = [NSMutableDictionary new];
        if(progressBlock) callback[kJLWebMediaProgressCallbackKey] = [progressBlock copy];
        if(completedBlock) callback[kJLWebMediaCompletedCallbackKey] = [completedBlock copy];
        [callbacks addObject:callback];
        self.URLCallbacksDict[url] = callbacks;
        
        if(isCreated)
        {
            createCallback();
        }
    });
}

- (void)removeCallbacksForURL:(NSURL *)url
{
    dispatch_barrier_async(self.barrierQueue, ^{
        [self.URLCallbacksDict removeObjectForKey:url];
    });
}

- (NSArray *)callbaksForURL:(NSURL *)url
{
    __block NSArray *callbacks;
    dispatch_barrier_sync(self.barrierQueue, ^{
        callbacks = self.URLCallbacksDict[url];
    });
    return callbacks;
}

@end

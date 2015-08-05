//
//  SDWebVideoManager.m
//  SDWebVideo
//
//  Created by jeremyLyu on 15/5/4.
//  Copyright (c) 2015年 PinGuo. All rights reserved.
//

#import "SDWebVideoManager.h"

@interface SDWebVideoCombinedOperation : NSObject <JLWebMediaOperation>
@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;
@property (nonatomic, copy) SDWebVideoNoParamsBlock cancelBlock;
@property (nonatomic, strong) NSOperation *cacheOperation;
@end

@implementation SDWebVideoCombinedOperation

- (void)setCancelBlock:(SDWebVideoNoParamsBlock)cancelBlock
{
    if(self.isCancelled){
        if (cancelBlock) {
            cancelBlock();
        }
        _cancelBlock = nil;
    } else{
        _cancelBlock = [cancelBlock copy];
    }
}

- (void)cancel
{
    self.cancelled = YES;
    if(self.cacheOperation)
    {
        [self.cacheOperation cancel];
        self.cacheOperation = nil;
    }
    if(self.cancelBlock)
    {
        self.cancelBlock();
        _cancelBlock = nil;
    }
}

@end

@interface SDWebVideoManager ()
//@property (nonatomic, strong) NSMutableArray *failedURLs;
@property (nonatomic, strong) NSMutableArray *runningOperations;
@end

@implementation SDWebVideoManager

+ (SDWebVideoManager *)sharedManager
{
    static dispatch_once_t once;
    static SDWebVideoManager *instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.videoCache = [SDVideoCache shareVideoCache];
        self.videoDownloader = [JLWebMediaDownloader shareDownloader];
        self.runningOperations = [NSMutableArray new];
    }
    return self;
}

//TODO: lxj dowloadImage 应该为video
- (id<JLWebMediaOperation>)downloadVideoWithURL:(NSURL *)url
                                       progress:(JLWebMediaDownloaderProgressBlock)progressBlock
                                      completed:(SDWebVideoCompletionBlock)completedBlock
{
    //纠错处理
    if(completedBlock == nil) return nil;
    //TODO: zct 预防 [NSURL URLWithString] 没有 URL schema 导致的错误
    if([url isKindOfClass:[NSString class]]) url = [NSURL URLWithString:(NSString *)url];
    if(![url isKindOfClass:[NSURL class]]) url = nil;
    
    __block SDWebVideoCombinedOperation *operation = [SDWebVideoCombinedOperation new];
    __weak SDWebVideoCombinedOperation *weakOperation = operation;
    @synchronized(self.runningOperations)
    {
        [self.runningOperations addObject:operation];
    }
    NSString *key = url.absoluteString;
    operation.cacheOperation = [self.videoCache queryDiskCacheFor:key done:^(NSString *videoPath, SDVideoCacheType cacheType) {
        //如果取消了
        if(operation.isCancelled)
        {
            @synchronized(self.runningOperations)
            {
                [self.runningOperations removeObject:operation];
            }
            return ;
        }
        
        if (videoPath) {
            @synchronized(self.runningOperations)
            {
                [self.runningOperations removeObject:operation];
            }
            dispatch_main_async_safe(^{
                completedBlock(videoPath, nil, YES, url);
            });
            return;
        }

        //TODO: 减少分支
        id subOperation = [self.videoDownloader downloadFileWithURL:url progress:progressBlock comletedBlock:^(NSString *tempPath, NSError *error, BOOL finished) {
            
            //TODO: LXJ 一些cancel的处理， remove operation
            if(weakOperation.isCancelled)
            {
                //做一些线程被取消的操作
            }
            else if(error)
            {
                //下载出错
                dispatch_main_sync_safe(^{
                    if(!weakOperation.isCancelled)
                    {
                        completedBlock(nil, error, finished, url);
                    }
                });
            }
            else
            {
                //直接存缓存
                [self.videoCache storeVideoWithPath:tempPath forKey:url.absoluteString completion:^(NSString *videoPath, BOOL success) {
                    if(success)
                    {
                        dispatch_main_sync_safe(^{
                            if(!weakOperation.isCancelled)
                            {
                                completedBlock(videoPath, nil, YES, url);
                            }
                        })
                    }
                }];
            }
            if(finished)
            {
                @synchronized(self.runningOperations)
                {
                    [self.runningOperations removeObject:operation];
                }
            }
        }];

        weakOperation.cancelBlock = ^{
            [subOperation cancel];
            @synchronized (self.runningOperations)
            {
                [self.runningOperations removeObject:weakOperation];
            }
        };
    }];
    
    return operation;
}

@end

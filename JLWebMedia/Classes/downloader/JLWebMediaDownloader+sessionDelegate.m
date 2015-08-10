//
//  JLWebMediaDownloader+downloadDelegate.m
//  JLWebMedia
//
//  Created by JeremyLyu_PinGuo on 15/6/10.
//  Copyright (c) 2015年 JeremyLyu. All rights reserved.
//

#import "JLWebMediaDownloader+sessionDelegate.h"
#import "JLWebMediaCompat.h"
#import "JLWebMediaFileControl.h"

static NSString *const JLWebMediaResumeDataSuffix = @".rds";
static NSString * const JLWebMediaDownLoaderCacheDir = @"cn.JLWebMedia.downloaderCacheDir";

@implementation JLWebMediaDownloader (sessionDelegate)

//下载任务完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSURL *url = task.originalRequest.URL;
    if(error)
    {
        //将已经下载的数据放入缓存中，以支持下次断点续传
        NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
        if([resumeData isKindOfClass:[NSData class]])
        {
             NSString *resumeDataPath = [self resumeDataPathWithURL:url];
            if(resumeDataPath)
            {
                [[JLWebMediaFileControl share] async_safe:^{
                    [resumeData writeToFile:resumeDataPath atomically:YES];
                }];
            }
        }
        //对应错误处理的回调
        NSArray *callbacks = [self callbaksForURL:url];
        jl_main_async_safe(^{
            for(NSDictionary *callback in callbacks)
            {
                JLWebMediaDownloaderCompletedBlock completeBlock = callback[kJLWebMediaCompletedCallbackKey];
                if(completeBlock) completeBlock(nil, error, YES);
            }
        })
    }
    
    [self removeCallbacksForURL:url];
}

//数据传输完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSURL *url = downloadTask.originalRequest.URL;
    //将下载的文件放入文件缓存中
    NSString *cacheFilePath = [self cachePathWithURL:url];
    BOOL success = [[JLWebMediaFileControl share] moveItemAtURL:location toURL:[[NSURL alloc] initFileURLWithPath:cacheFilePath] completion:nil];
    //TODO: 增加一点判错处理, 如果文件已经存在了，造成了文件操作错误，则需要将它移除了
    if(success == NO)
    {
        //判错处理的方法
    }
    //对外部进行回调
    NSArray *callbacks = [self callbaksForURL:url];
    jl_main_async_safe(^{
        for(NSDictionary *callback in callbacks)
        {
            JLWebMediaDownloaderCompletedBlock completeBlock = callback[kJLWebMediaCompletedCallbackKey];
            if(completeBlock) completeBlock(cacheFilePath, nil, YES);
        }
        //操作完成后，如果缓存依然存在则将缓存移除
        if([[JLWebMediaFileControl share] fileExistWithPath:cacheFilePath])
        {
            [[JLWebMediaFileControl share] removeItemForPath:cacheFilePath completion:^{
                NSLog(@"JLWebMediaDownloader:下载回调完成后，移除了下载缓存");
            }];
        }
    })
}

//数据传输过程
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //通知外部回调
    NSURL *url = downloadTask.originalRequest.URL;
    NSArray *callbacks = [self callbaksForURL:url];
    jl_main_async_safe(^{
        for(NSDictionary *callback in callbacks)
        {
            JLWebMediaDownloaderProgressBlock progressBlock = callback[kJLWebMediaProgressCallbackKey];
            if(progressBlock) progressBlock((NSInteger)totalBytesWritten, (NSInteger)totalBytesExpectedToWrite);
        }
    })
}

#pragma mark - 文件处理方法
- (NSString *)cacheDirPath
{
    NSString *direct = [NSTemporaryDirectory() stringByAppendingString:JLWebMediaDownLoaderCacheDir];
    return [[JLWebMediaFileControl share] getDirectoryWithPath:direct];
}

- (NSString *)cachePathWithURL:(NSURL *)url
{
    NSString *urlString = url.absoluteString;
    if(urlString.length == 0) return nil;
    NSString *cacheDirPath = [self cacheDirPath];
    NSString *fileName = [JLWebMediaFileControl cachedFileNameForKey:urlString];
    NSString *cacheFilePath = [cacheDirPath stringByAppendingPathComponent:fileName];
    return cacheFilePath;
}

- (NSString *)resumeDataPathWithURL:(NSURL *)url
{
    NSString *cacheFilePath = [self cachePathWithURL:url];
    if(cacheFilePath == nil) return nil;
    return [cacheFilePath stringByAppendingString:JLWebMediaResumeDataSuffix];
}

@end

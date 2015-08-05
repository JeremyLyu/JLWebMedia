//
//  JLWebMediaDownloader.h
//  JLWebMedia
//
//  Created by JeremyLyu_PinGuo on 15/6/10.
//  Copyright (c) 2015年 JeremyLyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLWebMediaOperation.h"

@interface NSURLSessionDownloadTask (JLWebMedia) <JLWebMediaOperation>

@end

typedef void(^JLWebMediaDownloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);
typedef void(^JLWebMediaDownloaderCompletedBlock)(NSString *tempPath, NSError *error, BOOL finished);

static NSString *const kJLWebMediaProgressCallbackKey = @"progress";
static NSString *const kJLWebMediaCompletedCallbackKey = @"completed";

@interface JLWebMediaDownloader : NSObject

//TODO: 在NSURLSession下，需要重新配置config,我觉得这个不是个很好的方式，需要下来研究
//下载超时，默认为15秒
@property (nonatomic, assign) NSTimeInterval downloadTimeout;

+ (JLWebMediaDownloader *)shareDownloader;

/**
 *  下载文件
 *
 *  @param url            文件的URL链接
 *  @param progressBlock  进度回调
 *  @param completedBlock 完成的回调
 *
 *  @return 下载任务
 */
- (id<JLWebMediaOperation>)downloadFileWithURL:(NSURL *)url
             progress:(JLWebMediaDownloaderProgressBlock)progressBlock
        comletedBlock:(JLWebMediaDownloaderCompletedBlock)completedBlock;


/**
 *  根据链接地址清除对应的回调
 *
 *  @param url 地址
 */
- (void)removeCallbacksForURL:(NSURL *)url;

/**
 *  根据链接地址获取对应的回调
 *
 *  @param url url地址
 *
 *  @return 回调数组
 */
- (NSArray *)callbaksForURL:(NSURL *)url;
@end

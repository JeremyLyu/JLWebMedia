//
//  SDWebVideoManager.h
//  SDWebVideo
//
//  Created by jeremyLyu on 15/5/4.
//  Copyright (c) 2015年 PinGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLWebMediaOperation.h"
#import "SDVideoCache.h"
#import "JLWebMediaDownloader.h"

typedef void(^SDWebVideoCompletionBlock)(NSString *videoPath, NSError *error, BOOL finished, NSURL *videoURL);

@interface SDWebVideoManager : NSObject
@property (nonatomic, strong) JLWebMediaDownloader *videoDownloader;
@property (nonatomic, strong) SDVideoCache *videoCache;

+ (SDWebVideoManager *)sharedManager;

/**
 *  下载视频
 *
 *  @param url            视频地址
 *  @param options        下载选项
 *  @param progressBlock  进度回调
 *  @param completedBlock 完成的回调
 *
 *  @return 网络线程
 */
- (id<JLWebMediaOperation>)downloadVideoWithURL:(NSURL *)url
                                       progress:(JLWebMediaDownloaderProgressBlock)progressBlock
                                      completed:(SDWebVideoCompletionBlock)completedBlock;
@end

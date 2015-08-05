//
//  JLWebMediaDownloader+downloadDelegate.h
//  JLWebMedia
//
//  Created by JeremyLyu_PinGuo on 15/6/10.
//  Copyright (c) 2015年 JeremyLyu. All rights reserved.
//

#import "JLWebMediaDownloader.h"

@interface JLWebMediaDownloader (sessionDelegate) <NSURLSessionDownloadDelegate>

/**
 *  根据url获取cache路径
 *
 *  @param url url地址
 *
 *  @return 路径，如果返回为nil 说明无法正确获取
 */
- (NSString *)cachePathWithURL:(NSURL *)url;

/**
 *  根据url获取终端的下载内容对应的resumeData路径
 *
 *  @param url url地址
 *
 *  @return resumeData路径，为nil说明无法正确获取
 */
- (NSString *)resumeDataPathWithURL:(NSURL *)url;
@end

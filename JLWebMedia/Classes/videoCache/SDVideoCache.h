//
//  SDVideoCache.h
//  SDWebVideo
//
//  Created by JeremyLyu_PinGuo on 15/5/5.
//  Copyright (c) 2015年 PinGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebVideoCompat.h"

typedef NS_ENUM(NSInteger, SDVideoCacheType) {
    SDVideoCacheTypeNone,
    SDVideoCacheTypeDisk
};

typedef void(^SDWebVideoQueryCompletedBlock)(NSString *videoPath, SDVideoCacheType cacheType);
typedef void(^SDWebVideoStoreCompletedBlock)(NSString *videoPath, BOOL success);

@interface SDVideoCache : NSObject
@property (nonatomic, assign) NSUInteger maxCacheSize;

+ (instancetype)shareVideoCache;

/**
 *  根据key获取缓存地址
 *
 *  @param key 一个独立的URL
 *
 *  @return 在缓存中的地址
 */
- (NSString *)videoPathFromKey:(NSString *)key;

/**
 *  异步的方式查询缓存是否存在
 *
 *  @param key       视频地址
 *  @param doneBlock 完成的回调
 *
 *  @return operation
 */
- (NSOperation *)queryDiskCacheFor:(NSString *)key done:(SDWebVideoQueryCompletedBlock)doneBlock;

/**
 *  将视频缓存到硬盘
 *
 *  @param tempPath 视频的临时文件地址
 *  @param key      视频的URL
 *  @param completion 完成的回调
 */
- (void)storeVideoWithPath:(NSString *)tempPath forKey:(NSString *)key completion:(SDWebVideoStoreCompletedBlock)completion;

/**
 *  删除指定的视频缓存
 *
 *  @param key 视频的URL地址
 */
- (void)removeVideoCacheForKey:(NSString *)key;

/**
 *  获取缓存大小
 *
 *  @return 缓存大小
 */
- (NSUInteger)getSize;

/**
 *  异步的方式清空缓存
 *
 *  @param completion 完成的回调
 */
- (void)clearCacheOnCompletion:(SDWebVideoNoParamsBlock)completion;
@end

//
//  SDWebVideoFile.h
//  SDWebVideo
//
//  Created by JeremyLyu_PinGuo on 15/4/30.
//  Copyright (c) 2015年 PinGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLWebMediaCompat.h"

@interface NSFileHandle (SDWebVideoFile)
@property (nonatomic, strong) NSString *filePath;
@end

@interface SDWebVideoFile : NSObject
@property (nonatomic, strong) dispatch_queue_t ioQueue;
@property (nonatomic, strong) NSFileManager *fileManager;


+ (instancetype)share;
+ (NSString *)cachedFileNameForKey:(NSString *)key;

/**
 *  根据路径获取一个目录地址，如果路径对应的目录不存在，会进行创建
 *
 *  @param path 目录的路径
 *
 *  @return 一个存在的目录地址，如果返回了Nil，说明无法获取到这个目录
 */
- (NSString *)getDirectoryWithPath:(NSString *)path;

/**
 *  异步的方式判断文件是否存在
 *
 *  @param path          文件的路径
 *  @param existBlock    存在的回调
 *  @param notExistBlock 不存在的回调
 */
- (void)fileExistWithPath:(NSString *)path exist:(void(^)(void))existBlock notExist:(void(^)(void))notExistBlock;

/**
 *  异步的方式删除文件
 *
 *  @param path          文件的路径
 *  @param comletedBlock 完成的回调
 */
- (void)removeItemForPath:(NSString *)path completion:(void(^)())comletedBlock;

/**
 *  根据路径清空一个目录
 *
 *  @param completion 完成的回调
 *  @param path       目录的路径
 */
- (void)clearDirectoryOnCompletion:(JLWebMediaNoParamsBlock)completion path:(NSString *)path;

/**
 *  获取目录的Size
 *
 *  @param path 路径，必须是个目录
 *
 *  @return 目录下的文件大小
 */
- (NSInteger)getSizeWithPath:(NSString *)path;

/**
 *  同步的方式判断文件是否存在
 *
 *  @param path 文件路径
 *
 *  @return 是否存在
 */
- (BOOL)fileExistWithPath:(NSString *)path;

//下载相关文件操作
- (NSString *)getDownloadTempDir;
- (NSFileHandle *)createFileHandleWithPath:(NSString *)path;

@end

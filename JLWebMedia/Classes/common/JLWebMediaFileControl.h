//
//  SDWebVideoFile.h
//  SDWebVideo
//
//  Created by JeremyLyu_PinGuo on 15/4/30.
//  Copyright (c) 2015年 PinGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLWebMediaCompat.h"

/*
 * JLWebMediaControl提供了一个独立的fileManager来进行对文件的操作，这些操作是放在一个
 * FIFO队列中的，所以使用它的方法来进行对文件安全的读写操作是线程安全。
 * 
 * 如果你期望在外部自己对文件进行读写操作，请把这些操作放在JLWebMediaControl的ioQueue中
 * 或者使用 default fileMananger
 */

@interface JLWebMediaFileControl : NSObject
@property (nonatomic, strong) dispatch_queue_t ioQueue;
@property (nonatomic, strong) NSFileManager *fileManager;


+ (instancetype)share;

//在ioQueue中，异步执行一个block,保证线程安全
- (void)async_safe:(JLWebMediaNoParamsBlock)block;
//在ioQueue中，同步执行一个block,保证线程安全
- (void)sync_safe:(JLWebMediaNoParamsBlock)block;

//根据key获取缓存文件名，建议使用URL链接地址
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
 *  同步的方式判断文件是否存在
 *
 *  @param path 文件路径
 *
 *  @return 是否存在
 */
- (BOOL)fileExistWithPath:(NSString *)path;

//同步线程安全做文件move操作
- (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath completion:(JLWebMediaNoParamsBlock)comletedBlock;
- (BOOL)moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL completion:(JLWebMediaNoParamsBlock)comletedBlock;

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

@end

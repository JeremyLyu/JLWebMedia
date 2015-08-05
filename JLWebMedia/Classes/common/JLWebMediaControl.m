//
//  SDWebVideoFile.m
//  SDWebVideo
//
//  Created by JeremyLyu_PinGuo on 15/4/30.
//  Copyright (c) 2015年 PinGuo. All rights reserved.
//

#import "JLWebMediaControl.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>

@interface JLWebMediaControl ()
@property (nonatomic, strong) NSString *dowloadPath;
@end

@implementation JLWebMediaControl

+ (instancetype)share
{
    static dispatch_once_t once;
    static JLWebMediaControl *instance;
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
        self.ioQueue = dispatch_queue_create("com.JLWebMedia.fileIO", DISPATCH_QUEUE_SERIAL);
        self.fileManager = [NSFileManager new];
    }
    return self;
}

- (void)async_safe:(JLWebMediaNoParamsBlock)block
{
    dispatch_async(_ioQueue, block);
}

- (void)sync_safe:(JLWebMediaNoParamsBlock)block
{
    dispatch_sync(_ioQueue, block);
}

#pragma mark - private fileManager
//根据路径创建一个目录
- (NSString *)getDirectoryWithPath:(NSString *)path
{
    __block NSString *dirPath = nil;
    dispatch_sync(_ioQueue, ^{
        BOOL isDirect = NO;
        BOOL exist = [_fileManager fileExistsAtPath:path isDirectory:&isDirect];
        if(exist && isDirect)
        {
            dirPath = path;
        }
        if([_fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL])
        {
            dirPath = path;
        }
    });
    return dirPath;
}

//判断文件是否存在
- (void)fileExistWithPath:(NSString *)path exist:(void(^)(void))existBlock notExist:(void(^)(void))notExistBlock
{
    dispatch_async(_ioQueue, ^{
        BOOL exsit = [_fileManager fileExistsAtPath:path];
        
        if(exsit)
        {
            if(existBlock) existBlock();
        }
        else
        {
            if(notExistBlock) notExistBlock();
        }
    });
}

- (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath completion:(JLWebMediaNoParamsBlock)comletedBlock
{
    __block BOOL success = NO;
    dispatch_sync(_ioQueue, ^{
        success = [_fileManager moveItemAtPath:srcPath toPath:dstPath error:nil];
    });
    return success;
}

- (BOOL)moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL completion:(JLWebMediaNoParamsBlock)comletedBlock
{
    __block BOOL success = NO;
    dispatch_sync(_ioQueue, ^{
        success = [_fileManager moveItemAtURL:srcURL toURL:dstURL error:nil];
    });
    return success;

}


- (void)removeItemForPath:(NSString *)path completion:(void(^)())comletedBlock
{
    dispatch_async(_ioQueue, ^{
        [_fileManager removeItemAtPath:path error:nil];
        if(comletedBlock)
        {
            comletedBlock();
        }
    });
}

- (void)clearDirectoryOnCompletion:(JLWebMediaNoParamsBlock)completion path:(NSString *)path
{
    dispatch_async(self.ioQueue, ^{
        [_fileManager removeItemAtPath:path error:nil];
        [_fileManager createDirectoryAtPath:path
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:NULL];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (NSInteger)getSizeWithPath:(NSString *)path
{
    __block NSUInteger size = 0;
    
    dispatch_sync(self.ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:path];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return size;
}

- (BOOL)fileExistWithPath:(NSString *)path
{
    __block BOOL isExsit = NO;
    //TODO: 判断文件是否存在，有必要放到 IO queue 里面么
    isExsit = [_fileManager fileExistsAtPath:path];
    return isExsit;
}

+ (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return filename;
}

@end

//
//  SDVideoCache.m
//  SDWebVideo
//
//  Created by JeremyLyu_PinGuo on 15/5/5.
//  Copyright (c) 2015年 PinGuo. All rights reserved.
//

#import "SDVideoCache.h"
#import "SDWebVideoFile.h"
#import "SDWebVideoCompat.h"

@interface SDVideoCache ()
@property (nonatomic, strong) NSString *protectedDir;
@property (nonatomic, strong) NSString *cacheDir;
@end

#define SDWebVideoCacheDirName @"com.SDWebVideo.Cache"

@implementation SDVideoCache

+ (instancetype)shareVideoCache
{
    static dispatch_once_t once;
    static SDVideoCache *instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *diskCachePath = [paths[0] stringByAppendingPathComponent:SDWebVideoCacheDirName];
        self.cacheDir = [diskCachePath stringByAppendingPathComponent:@"default"];
        self.protectedDir = [diskCachePath stringByAppendingPathComponent:@"protected"];
    }
    return self;
}

- (NSString *)videoPathFromKey:(NSString *)key
{
    NSString *dirPath = [self videoCacheDirFromKey:key];
    if(dirPath == nil) return nil;
    NSString *path = [dirPath stringByAppendingPathComponent:[SDWebVideoFile cachedFileNameForKey:key]];
    path = [path stringByAppendingString:@".mp4"];
    return path; 
}

- (NSString *)videoCacheDirFromKey:(NSString *)key
{
    NSString *dirPath = nil;
    if([key hasPrefix:@"protected://"] || [key hasPrefix:@"file://"])
        dirPath = self.protectedDir;
    else
        dirPath =  self.cacheDir;
    return [[SDWebVideoFile share] getDirectoryWithPath:dirPath];
}

- (NSOperation *)queryDiskCacheFor:(NSString *)key done:(SDWebVideoQueryCompletedBlock)doneBlock
{
    if(!doneBlock) return nil;
    if(!key)
    {
        doneBlock(nil, SDVideoCacheTypeNone);
        return nil;
    }
    NSOperation *operation = [NSOperation new];
    
    NSString *path = [self videoPathFromKey:key];
    
    dispatch_async([SDWebVideoFile share].ioQueue, ^{
        if(operation.isCancelled) return ;
        BOOL exsit = [[SDWebVideoFile share] fileExistWithPath:path];
        NSString *videoPath = exsit ? path : nil;
        dispatch_main_async_safe(^{
             if(doneBlock) doneBlock(videoPath, SDVideoCacheTypeDisk);
        });
    });
    return operation;
}

- (void)storeVideoWithPath:(NSString *)tempPath forKey:(NSString *)key completion:(SDWebVideoStoreCompletedBlock)completion;
{
    //TODO: 这里需要增加一个对 tempPath 和 key的一个保护判断
    SDWebVideoFile *webVideoFile = [SDWebVideoFile share];
    NSString *path = [self videoPathFromKey:key];
    dispatch_async(webVideoFile.ioQueue, ^{
        BOOL success = [webVideoFile.fileManager moveItemAtPath:tempPath toPath:path error:nil];
        dispatch_main_async_safe(^{
          if(completion) completion(path, success);
        })
    });
}

- (void)removeVideoCacheForKey:(NSString *)key
{
    NSString *path = [self videoPathFromKey:key];
    [[SDWebVideoFile share] removeItemForPath:path completion:^{
    }];
}

- (void)clearCacheOnCompletion:(SDWebVideoNoParamsBlock)completion
{
    NSString *path = [[SDWebVideoFile share] getDirectoryWithPath:self.cacheDir];
    [[SDWebVideoFile share] clearDirectoryOnCompletion:completion path:path];
}

- (NSUInteger)getSize {
    NSString *path = [[SDWebVideoFile share] getDirectoryWithPath:self.cacheDir];
    return [[SDWebVideoFile share] getSizeWithPath:path];
}

@end

//
//  SDVideoCache.m
//  SDWebVideo
//
//  Created by JeremyLyu_PinGuo on 15/5/5.
//  Copyright (c) 2015年 PinGuo. All rights reserved.
//

#import "SDVideoCache.h"
#import "JLWebMediaFileControl.h"

@interface SDVideoCache ()
@property (nonatomic, strong) NSString *protectedDir;
@property (nonatomic, strong) NSString *cacheDir;
@end

#define JLWebVideoCacheDirName @"com.JLWebVideo.Cache"

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
        NSString *diskCachePath = [paths[0] stringByAppendingPathComponent:JLWebVideoCacheDirName];
        self.cacheDir = [diskCachePath stringByAppendingPathComponent:@"default"];
        self.protectedDir = [diskCachePath stringByAppendingPathComponent:@"protected"];
    }
    return self;
}

- (NSString *)videoPathFromKey:(NSString *)key
{
    NSString *dirPath = [self videoCacheDirFromKey:key];
    if(dirPath == nil) return nil;
    NSString *path = [dirPath stringByAppendingPathComponent:[JLWebMediaFileControl cachedFileNameForKey:key]];
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
    return [[JLWebMediaFileControl share] getDirectoryWithPath:dirPath];
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
    
    [[JLWebMediaFileControl share] async_safe:^{
        if(operation.isCancelled) return ;
        BOOL exsit = [[JLWebMediaFileControl share] fileExistWithPath:path];
        NSString *videoPath = exsit ? path : nil;
        jl_main_async_safe(^{
            if(doneBlock) doneBlock(videoPath, SDVideoCacheTypeDisk);
        });

    }];
    return operation;
}

- (void)storeVideoWithPath:(NSString *)tempPath forKey:(NSString *)key completion:(SDWebVideoStoreCompletedBlock)completion;
{
    //TODO: 这里需要增加一个对 tempPath 和 key的一个保护判断
    //TODO: 这里需要修改
    JLWebMediaFileControl *webVideoFile = [JLWebMediaFileControl share];
    NSString *path = [self videoPathFromKey:key];
    if([webVideoFile fileExistWithPath:path])
    {
        jl_main_async_safe(^{
           if(completion) completion(path, YES);
        });
        return ;
    }
    dispatch_async(webVideoFile.ioQueue, ^{
        BOOL success = [webVideoFile.fileManager moveItemAtPath:tempPath toPath:path error:nil];
        jl_main_async_safe(^{
            if(completion) completion(path, success);
        });
    });
}

- (void)removeVideoCacheForKey:(NSString *)key
{
    NSString *path = [self videoPathFromKey:key];
    [[JLWebMediaFileControl share] removeItemForPath:path completion:^{
        
    }];
}

- (void)clearCacheOnCompletion:(JLWebMediaNoParamsBlock)completion
{
    NSString *path = [[JLWebMediaFileControl share] getDirectoryWithPath:self.cacheDir];
    [[JLWebMediaFileControl share] clearDirectoryOnCompletion:completion path:path];
}

- (NSUInteger)getSize {
    NSString *path = [[JLWebMediaFileControl share] getDirectoryWithPath:self.cacheDir];
    return [[JLWebMediaFileControl share] getSizeWithPath:path];
}

@end

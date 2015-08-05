//
//  JLWebMediaCompat.h
//  JLWebMedia
//
//  Created by JeremyLyu_PinGuo on 15/6/11.
//  Copyright (c) 2015年 JeremyLyu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^JLWebMediaNoParamsBlock)(void);

#define jl_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define jl_main_async_safe(block)\
dispatch_async(dispatch_get_main_queue(), block);

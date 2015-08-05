//
//  SDWebVideoCompat.h
//  SDWebVideo
//
//  Created by JeremyLyu_PinGuo on 15/4/29.
//  Copyright (c) 2015年 PinGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TargetConditionals.h>
#import <UIKit/UIKit.h>

typedef void(^SDWebVideoNoParamsBlock)();

#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


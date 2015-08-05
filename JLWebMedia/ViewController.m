//
//  ViewController.m
//  JLWebMedia
//
//  Created by jeremyLyu on 15/8/5.
//  Copyright (c) 2015年 jeremyLyu. All rights reserved.
//

#import "ViewController.h"
#import "JLWebMediaDownloader.h"
#import "SDVideoCache.h"
#import "JLWebVideoManager.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelProgress;
@property (weak, nonatomic) IBOutlet UIButton *btnDownLoad;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)downLoadBtnPressed:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1308/15/c2/24494083_1376530583817.jpg"];
    self.btnDownLoad.enabled = NO;
    [[JLWebVideoManager sharedManager] downloadVideoWithURL:url progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        self.labelProgress.text = [NSString stringWithFormat:@"%.0ld/%.0ld", (long)receivedSize, (long)expectedSize];

    } completed:^(NSString *videoPath, NSError *error, BOOL finished, NSURL *videoURL) {
         self.btnDownLoad.enabled = YES;
    }];
}

- (IBAction)clearCacheBtnPressed:(id)sender
{
    [[SDVideoCache shareVideoCache] clearCacheOnCompletion:nil];
}

@end

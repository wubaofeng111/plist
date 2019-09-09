//
//  ProcTableViewCell.m
//  testview
//
//  Created by friday on 2019/9/6.
//  Copyright © 2019 friday. All rights reserved.
//

#import "ProcTableViewCell.h"

@implementation AVAssetExportSessionItem

-(id)initWithStartTime:(CGFloat)starttime EndTime:(CGFloat)endTime AndAllTime:(CGFloat)allTime Type:(int)type And:(nonnull AVMutableComposition *)copyedCompostion
{
    if (self = [super init]) {
        
        
        CMTimeRange range = CMTimeRangeMake(CMTimeMake(starttime, 1), CMTimeMake(endTime, 1));
        
        
        
        NSString *outputStr = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        NSString *timeStr = [NSString stringWithFormat:@"%lu.mp4",clock()];
        
        outputStr = [outputStr stringByAppendingPathComponent:timeStr];
        unlink(outputStr.UTF8String);
        NSURL *outputUrl = [NSURL fileURLWithPath:outputStr];
        
        AVAssetExportSession *lAVAssetExportSession = [[AVAssetExportSession alloc]initWithAsset:copyedCompostion presetName:AVAssetExportPreset640x480 ];
        
        
        lAVAssetExportSession.videoComposition = nil ;
        lAVAssetExportSession.outputURL = outputUrl;
        lAVAssetExportSession.outputFileType=AVFileTypeMPEG4;
        [lAVAssetExportSession setTimeRange:range];
        [lAVAssetExportSession exportAsynchronouslyWithCompletionHandler:^{
            NSLog(@"ready");
            NSLog(@"%@",lAVAssetExportSession.error);
            [self.timer invalidate];
            self.timer = nil;
        }];
        self.section = lAVAssetExportSession;
        
        self.timer =[NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer * _Nonnull timer) {
            self.cell.progress.progress = self.section.progress;
        }];
        
    }
    return self;
}



@end

@implementation ProcTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

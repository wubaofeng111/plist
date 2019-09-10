//
//  BFAVPlayerViewController.m
//  testview
//
//  Created by friday on 2019/9/10.
//  Copyright © 2019 friday. All rights reserved.
//

#import "BFAVPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"


@interface BFAVPlayerViewController ()
{
    AVPlayerLayer *playLayer;
    AVPlayer      *player;
    AVPlayerItem  *playItem;
    __weak IBOutlet UIView *mPlayerView;
    
    __weak IBOutlet UIProgressView *mProgress;
    GPUImageMovie *movieFile;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
    NSTimer       *timer;
    
    
    
}
@end

@implementation BFAVPlayerViewController

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *sampleURL = [NSURL fileURLWithPath:_videoPath];
    movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = NO;
    filter = [[GPUImagePixellateFilter alloc] init];
    //    filter = [[GPUImageUnsharpMaskFilter alloc] init];
    
    [movieFile addTarget:filter];
    
    // Only rotate the video for display, leave orientation the same for recording
    GPUImageView *filterView = (GPUImageView *)self.view;
    [filter addTarget:filterView];
    
    // In addition to displaying to the screen, write out a processed version of the movie to disk
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
    [filter addTarget:movieWriter];
    
    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
    movieWriter.shouldPassthroughAudio = YES;
    movieFile.audioEncodingTarget = movieWriter;
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    
    [movieWriter startRecording];
    [movieFile startProcessing];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                             target:self
                                           selector:@selector(retrievingProgress)
                                           userInfo:nil
                                            repeats:YES];
    
    [movieWriter setCompletionBlock:^{
        [filter removeTarget:movieWriter];
        [movieWriter finishRecording];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [timer invalidate];
            mProgress.progress = 1;
        });
    }];

    
    
    return;
    
    
    //1
    AVURLAsset *asset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:_videoPath]];
    
    //2
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    AVVideoComposition *composition1 = [AVVideoComposition videoCompositionWithAsset:asset1 applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
        //3
        CIImage *source = request.sourceImage.imageByClampingToExtent;
        int currentTime = request.compositionTime.value / request.compositionTime.timescale;
        if (currentTime < 3) {
            [request finishWithImage:source context:nil];
        } else {
            [filter setValue:source forKey:kCIInputImageKey];
            //4
            CIImage *output = [filter.outputImage imageByCroppingToRect:request.sourceImage.extent];
            [request finishWithImage:output context:nil];
        }
    }];
    
    //5
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset1];
    item.videoComposition = composition1;
    
    
    playLayer = [[AVPlayerLayer alloc]init];
    [mPlayerView.layer addSublayer:playLayer];
    playLayer.frame = mPlayerView.bounds;
    
//    playItem = [[AVPlayerItem alloc]initWithURL:[NSURL fileURLWithPath:_videoPath]];
    
    player = [[AVPlayer alloc]initWithPlayerItem:item];
    [playLayer setPlayer:player];
    
    
    
    NSValue *time1 = [NSValue valueWithCMTime:kCMTimeZero];
    NSValue *time2 = [NSValue valueWithCMTime:playItem.duration];
    
    dispatch_queue_t curqueue = dispatch_queue_create("avplayer_queue", 0);
    
    [player addBoundaryTimeObserverForTimes:@[time1,time2] queue:curqueue usingBlock:^{
        
    }];
    
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)play:(id)sender {
    
    if (player.status == AVPlayerStatusReadyToPlay) {
        [player play];
    }
    
}
- (IBAction)pause:(id)sender {
    [player pause];
}

- (IBAction)stop:(id)sender {
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

#import "SimpleVideoFileFilterViewController.h"

@implementation SimpleVideoFileFilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [player play];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    playerLayer.frame = mPlayerView.bounds;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    NSURL *sampleURL = [NSURL fileURLWithPath:_videoPath];
    
    playerItem = [[AVPlayerItem alloc]initWithURL:sampleURL];
    player = [AVPlayer playerWithPlayerItem:playerItem];
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = CGRectMake(0, 0, 320, 480);
    [mPlayerView.layer addSublayer:playerLayer];
    mPlayerView.hidden = YES;
    
    
    
    movieFile = [[GPUImageMovie alloc] initWithPlayerItem:playerItem];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = YES;
    
    filter = [[GPUImageGrayscaleFilter alloc] init];
//    filter = [[GPUImageUnsharpMaskFilter alloc] init];
    
    [movieFile addTarget:filter];

    // Only rotate the video for display, leave orientation the same for recording
    GPUImageView *filterView = mGPUImage;
    [filter addTarget:filterView];

    // In addition to displaying to the screen, write out a processed version of the movie to disk
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];

//    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
//    [filter addTarget:movieWriter];

    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
//    movieWriter.shouldPassthroughAudio = YES;
//    movieFile.audioEncodingTarget = movieWriter;
//    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    
//    [movieWriter startRecording];
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
            self.progressLabel.text = @"100%";
        });
    }];
}

- (IBAction)changeTime:(UISlider*)sender {
    
    CGFloat timeSecond = CMTimeGetSeconds(playerItem.duration);
    
    [player seekToTime:CMTimeMake(timeSecond*sender.value, 1)];
}
- (IBAction)play:(id)sender {
    [player play];
}
- (IBAction)pause:(id)sender {
    [player pause];
}


- (void)retrievingProgress
{
    self.progressLabel.text = [NSString stringWithFormat:@"%d%%", (int)(movieFile.progress * 100)];
}

- (void)viewDidUnload
{
    [self setProgressLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)updatePixelWidth:(id)sender
{
//    [(GPUImageBrightnessFilter *)filter setBrightness:[(UISlider *)sender value]];
//    [(GPUImageWhiteBalanceFilter *)filter setTemperature:[(UISlider *)sender value]];
}

- (void)dealloc {
    
}
@end

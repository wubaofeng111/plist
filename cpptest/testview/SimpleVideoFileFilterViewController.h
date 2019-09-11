#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import <AVFoundation/AVFoundation.h>

@interface SimpleVideoFileFilterViewController : UIViewController
{
    GPUImageMovie *movieFile;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
    
    __weak IBOutlet GPUImageView *mGPUImage;
    
    __weak IBOutlet UIView *mPlayerView;
    
    
    AVPlayerItem        *playerItem;
    AVPlayer            *player;
    AVPlayerLayer       *playerLayer;
    NSTimer * timer;
}
@property(nonatomic,retain)NSString *videoPath;
@property (retain, nonatomic) IBOutlet UILabel *progressLabel;
- (IBAction)updatePixelWidth:(id)sender;

@end

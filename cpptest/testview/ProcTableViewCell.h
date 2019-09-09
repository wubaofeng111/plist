//
//  ProcTableViewCell.h
//  testview
//
//  Created by friday on 2019/9/6.
//  Copyright © 2019 friday. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>



NS_ASSUME_NONNULL_BEGIN

@class ProcTableViewCell;


@interface AVAssetExportSessionItem:NSObject
-(id)initWithStartTime:(CGFloat)time EndTime:(CGFloat)endTime AndAllTime:(CGFloat)allTime  Type:(int)type And:(AVMutableComposition*)compositon;
@property(nonatomic,retain)AVAssetExportSession *section;
@property(nonatomic,assign)ProcTableViewCell *cell;
@property(nonatomic,retain)NSTimer *timer;
@end

@interface ProcTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@end

NS_ASSUME_NONNULL_END

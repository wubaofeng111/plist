//
//  ProcessVideoViewController.h
//  testview
//
//  Created by friday on 2019/9/4.
//  Copyright © 2019 friday. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
@class AECollectionViewCell;

typedef NS_ENUM(NSInteger,CutItemType)
{
    CutItemType_Normal,
    CutItemType_Cut, /// 切割线 保留原始图片，原始时间信息
    CutItemType_Splited, /// 处理后的图片
};


@interface ProcessVideoItem:NSObject
@property(nonatomic,assign)int    index;
@property(nonatomic,assign)CGSize size;
@property(nonatomic,assign)CutItemType type;
@property(nonatomic,assign)CGFloat time;
@property(nonatomic,assign)CGFloat fActTime;
@property(nonatomic,assign)CMTime  cTime;
@property(nonatomic,assign)CMTime  actTime;
@property(nonatomic,retain)NSString *curPreviewImgPath;
@property(nonatomic,retain)UIImage  *placeHodelImg;
@property(nonatomic,weak)AVAssetImageGenerator *imageGenerator;
@property(nonatomic,weak)AECollectionViewCell  *cell;

-(void)LoadImage;
@end


@interface ProcessVideoViewController : UIViewController
@property(nonatomic,assign)NSString * filePath;
@property(nonatomic,retain)NSMutableArray *proviewImgItems;
@end

NS_ASSUME_NONNULL_END

//
//  ProcessVideoViewController.m
//  testview
//
//  Created by friday on 2019/9/4.
//  Copyright © 2019 friday. All rights reserved.
//

#import "ProcessVideoViewController.h"

#import "AECollectionViewCell.h"
#import "ProcTableViewCell.h"


static NSCache *mCashe = nil;

@implementation ProcessVideoItem
@synthesize imageGenerator;

-(void)dealloc
{
    [mCashe removeAllObjects];
}

-(id)init
{
    if (self = [super init]) {
        if (mCashe == nil) {
            mCashe = [[NSCache alloc]init];
            [mCashe setCountLimit:1000];
            
            
        }
    }
    return self;
}

-(void)LoadImage
{
    
    if (self.curPreviewImgPath == nil) {
        self.cell.coverIV.image = self.placeHodelImg;
        NSArray *array = @[[NSValue valueWithCMTime:self.cTime]];
        __weak ProcessVideoItem*itm = self;
        
        [imageGenerator generateCGImagesAsynchronouslyForTimes:array completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
            @autoreleasepool {
                UIImage *img = [[UIImage alloc] initWithCGImage:image scale:3 orientation:UIImageOrientationUp];
                
                itm.actTime = actualTime;
                itm.fActTime = CMTimeGetSeconds(actualTime);
                clock_t ct = clock();
                NSString *filePath = NSTemporaryDirectory();
                filePath = [[NSString alloc]initWithFormat:@"%@/%lu.png",filePath,ct];
                NSData *data = UIImageJPEGRepresentation(img, 0.2);
                itm.curPreviewImgPath = filePath;
                [data writeToFile:filePath atomically:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    itm.cell.coverIV.image = [UIImage imageWithData:data];
                    if (itm.cell.coverIV.image != nil) {
                        [mCashe setObject:itm.cell.coverIV.image forKey:filePath ];
                    }
                    
                });
            }
        }];
    }else{
        
        UIImage *img = [mCashe objectForKey:self.curPreviewImgPath];
        
        if (img != nil) {
            self.cell.coverIV.image = img;
            return;
        }
        img = [[UIImage alloc]initWithContentsOfFile:self.curPreviewImgPath];
        if (img != nil) {
            self.cell.coverIV.image = img;
            return;
        }
        
        self.cell.coverIV.image = self.placeHodelImg;
        
        
    }
    
    
    
}
@end


@interface ProcessVideoViewController()<UICollectionViewDelegate,UICollectionViewDataSource,CutItemProtocol,UICollectionViewDelegateFlowLayout,UICollectionViewDataSourcePrefetching,UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UIView *TagView;
    
    __weak IBOutlet UITableView *mTableView;
    __weak IBOutlet  UICollectionView *mainView;
    NSString         *reuseId;
    AVAssetImageGenerator *imageGenerator;
    NSMutableDictionary   *questDict;
    
    AVMutableComposition  *pAVMutableComposition;
    AVAssetExportSession  *pAVAssetExportSession;
    
    CGFloat                set_duration;
    BOOL                   startCorver;
    
    NSMutableArray         *cutsections;
}
@property(nonatomic,assign)CGRect frame;
@property(nonatomic,assign)CGRect bounds;
@property(nonatomic,assign)UIColor*backgroundColor;
@end

@implementation ProcessVideoViewController

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.view bringSubviewToFront:TagView];
}

-(CGRect)frame
{
    return self.view.frame;
}

-(CGRect)bounds
{
    return self.view.bounds;
}

-(void)addSubView:(UIView*)view
{
    [self.view addSubview:view];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.view.backgroundColor = backgroundColor;
}



-(void)CutItemWithCell:(UICollectionViewCell *)cell WithItem1:(CGFloat)poi WithItem2:(CGFloat)item2
{
    NSLog(@"%@",cell);
    NSLog(@"%@",TagView);
    CGRect pt = [self.view convertRect:cell.frame fromView:mainView];
    NSLog(@"%@",NSStringFromCGRect(pt));
    pt = [mainView convertRect:cell.frame toView:self.view];
    NSLog(@"%@",NSStringFromCGRect(pt));
    
    NSIndexPath *path = [mainView indexPathForCell:cell];
    ProcessVideoItem *item = [_proviewImgItems objectAtIndex:path.row];
    item.type = CutItemType_Cut;
    item.size = CGSizeMake(5, 100);
    
    CGFloat time1 = item.time;
    CGFloat timeLong = 0;
    if (path.row == _proviewImgItems.count - 1) {
        timeLong = set_duration - time1;
    }else{
        ProcessVideoItem *itemNext = [_proviewImgItems objectAtIndex:path.row+1];
        timeLong = itemNext.time -item.time;
    }
    
    NSString*temp   =  NSTemporaryDirectory();
    UIImage* image = [UIImage imageNamed:item.curPreviewImgPath];
    
    CGFloat image1Time = time1 ;
    CGFloat image2Time = time1 + timeLong * poi;
    CGSize imgSize = image.size;
    
    CGImageRef img1 = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, 0, imgSize.width*poi, imgSize.height));
    UIImage *image1 = [UIImage imageWithCGImage:img1];
    NSData  *data1  = UIImageJPEGRepresentation(image1, 1.0);
    
   
    NSString*image1Name = [NSString stringWithFormat:@"%lu.png",clock()];
    image1Name = [temp stringByAppendingPathComponent:image1Name];
    [data1 writeToFile:image1Name atomically:YES];
    
    ProcessVideoItem *img1Item = [[ProcessVideoItem alloc]init];
    img1Item.size = CGSizeMake(100*poi, 100);
    img1Item.curPreviewImgPath = image1Name;
    img1Item.time = image1Time;
    img1Item.type = CutItemType_Splited;
    
    CGImageRef img2 = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(imgSize.width*poi, 0, imgSize.width*item2, imgSize.height));
    
    UIImage *image2 = [UIImage imageWithCGImage:img2];
    NSData  *data2  = UIImageJPEGRepresentation(image2, 1.0);
    NSString*image2Name = [NSString stringWithFormat:@"%lu.png",clock()];
    image2Name = [temp stringByAppendingPathComponent:image2Name];
    [data2 writeToFile:image2Name atomically:YES];
    
    ProcessVideoItem *img2Item = [[ProcessVideoItem alloc]init];
    img2Item.curPreviewImgPath = image2Name;
    img2Item.size = CGSizeMake(100*item2, 100);
    img2Item.time = image2Time;
    img2Item.type = CutItemType_Splited;
    
    [_proviewImgItems insertObject:img2Item atIndex:path.row+1];
    [_proviewImgItems insertObject:img1Item atIndex:path.row];
    [mainView reloadData];
    
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProcessVideoItem *item = [_proviewImgItems objectAtIndex:indexPath.row];
    return item.size;
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.proviewImgItems.count;
}



-(__kindof UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AECollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    ProcessVideoItem *item = [_proviewImgItems objectAtIndex:indexPath.row];
    cell.delegate = self ;
    cell.item     = item;
    item.cell     = cell;
    
    if (item.type == CutItemType_Cut) {
        cell.coverIV.image = nil;
        cell.backgroundColor = [UIColor redColor];
    }else{
        if (item.type == CutItemType_Splited) {
            cell.backgroundColor = [UIColor blueColor];
        }else{
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        [item LoadImage];
    }

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
//    [self LoadImageWithIndexPaths:indexPaths];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    @autoreleasepool {
        NSArray *indexpaths = [mainView indexPathsForVisibleItems];
        [self LoadImageWithIndexPaths:indexpaths];
    }
    
    
}

-(void)LoadImageWithIndexPaths:(NSArray*)indexpaths
{
    
    NSMutableArray *items = [[NSMutableArray alloc]init];
    if (questDict == nil) {
        questDict = [[NSMutableDictionary alloc]init];
    }
    [indexpaths enumerateObjectsUsingBlock:^(NSIndexPath*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ProcessVideoItem*itm = [self.proviewImgItems objectAtIndex:obj.row];
        if ([[NSFileManager defaultManager] fileExistsAtPath:itm.curPreviewImgPath]) {
            
        }else{
            NSValue *value = [NSValue valueWithCMTime:itm.cTime];
            [items addObject:value];
            [questDict setObject:itm forKey:value];
        }
    }];
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:items completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        UIImage *img = [[UIImage alloc] initWithCGImage:image scale:3 orientation:UIImageOrientationUp];
        
        NSValue *value = [NSValue valueWithCMTime:requestedTime];
        ProcessVideoItem*itm = [questDict objectForKey:value];
        [questDict removeObjectForKey:value];
        itm.actTime = actualTime;
        itm.fActTime = CMTimeGetSeconds(actualTime);
        clock_t ct = clock();
        NSString *filePath = NSTemporaryDirectory();
        filePath = [[NSString alloc]initWithFormat:@"%@/%lu.png",filePath,ct];
        NSData *data = UIImageJPEGRepresentation(img, 0.2);
        itm.curPreviewImgPath = filePath;
        [data writeToFile:filePath atomically:YES];
        
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [mainView reloadData];
//        });
    }];
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"%@",[collectionView cellForItemAtIndexPath:indexPath]);
    return;
    
    
    
    
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == mainView) {
        
        if (!startCorver) {
            return;
        }
        NSArray *visiCells = [mainView visibleCells];
        AECollectionViewCell *cell = nil;
        CGRect cellFrame;
        CGRect viewFrame = TagView.frame;
        
        
        
        CGPoint pt1 = CGPointMake(CGRectGetMinX(viewFrame), CGRectGetMidY(viewFrame));
        CGPoint pt2 = CGPointMake(CGRectGetMaxX(viewFrame), CGRectGetMidY(viewFrame));
        for (UIView *view in visiCells) {
            CGRect frame = [mainView convertRect:view.frame toView:self.view];
            
            if (CGRectContainsPoint(frame, pt1)||CGRectContainsPoint(frame, pt2)) {
                cell = (AECollectionViewCell*)view;
                cellFrame = frame;
                break;
            }
        }
        
        
        [cell setCorver:viewFrame.origin.x - cellFrame.origin.x];
        
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cutsections.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProcTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProcTableViewCell.xib"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ProcTableViewCell" owner:nil options:nil] firstObject ];
    }
    
    AVAssetExportSessionItem *item = [cutsections objectAtIndex:indexPath.row];
    item.cell = cell;
    
    return cell;
}


-(IBAction)Cut
{
    ProcessVideoItem *lastCutItem = nil;
    for ( int i = 0;i< _proviewImgItems.count;i++) {

        ProcessVideoItem*item = _proviewImgItems[i];
        
        if (item.type != CutItemType_Cut) {
            continue;
        }
        
        if (lastCutItem == nil) {
            /// 第一刀
            ProcessVideoItem *nextItem = _proviewImgItems[i+1];
            AVAssetExportSessionItem *pAVAssetExportSessionItem = [[AVAssetExportSessionItem alloc]initWithStartTime:0 EndTime:nextItem.time AndAllTime:set_duration Type:0 And:[pAVMutableComposition mutableCopy]];
            
            [cutsections addObject:pAVAssetExportSessionItem];
            [mTableView reloadData];
        }else{
            ProcessVideoItem *frontItem = _proviewImgItems[lastCutItem.index+1];
            
            ProcessVideoItem *nextItem  = _proviewImgItems[i+1];
            
            AVAssetExportSessionItem *pAVAssetExportSessionItem = [[AVAssetExportSessionItem alloc]initWithStartTime:frontItem.time EndTime:nextItem.time AndAllTime:set_duration Type:1 And:[pAVMutableComposition mutableCopy]];
            
            [cutsections addObject:pAVAssetExportSessionItem];
            [mTableView reloadData];
        }
        
        lastCutItem = item;
        lastCutItem.index = i;
    }
    
    
    if(lastCutItem != nil)
    {
        ProcessVideoItem *frontItem = _proviewImgItems[lastCutItem.index+1];
        
        AVAssetExportSessionItem *pAVAssetExportSessionItem = [[AVAssetExportSessionItem alloc]initWithStartTime:frontItem.time EndTime:set_duration AndAllTime:set_duration Type:2 And:[pAVMutableComposition mutableCopy]];
        
        [cutsections addObject:pAVAssetExportSessionItem];
        [mTableView reloadData];
    }
    
    
    
}

- (IBAction)startCorver:(id)sender {
//    startCorver = !startCorver;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 800, 100)];
    view.backgroundColor = [UIColor redColor];
    [mainView addSubview:view];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundColor = [UIColor whiteColor];
    
    cutsections = [[NSMutableArray alloc]init];
    
    
    
    reuseId = @"AECollectionViewCell";
    
    AVMutableComposition *compos = [AVMutableComposition composition];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)mainView.collectionViewLayout;
    layout.itemSize = CGSizeMake(100, 100);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing =0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    
    mainView.delegate = self;
    mainView.dataSource = self;
    mainView.prefetchDataSource = self;
    [mainView registerClass:[AECollectionViewCell class] forCellWithReuseIdentifier:reuseId];
    [self addSubView:mainView];
    
    AVAsset *set = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.filePath]];
    CGFloat duration = CMTimeGetSeconds(set.duration);
    CMTime trimDuration =set.duration;
    pAVMutableComposition = [AVMutableComposition composition];
    
    AVAssetTrack *pAVAssetTrackVideo = nil;
    AVAssetTrack *pAVAssetTrackAudio = nil;
    NSError *error = nil;
    
    if ([[set tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        pAVAssetTrackVideo = [set tracksWithMediaType:AVMediaTypeVideo][0];
    }
    
    if ([[set tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        pAVAssetTrackAudio = [set tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    if (pAVAssetTrackVideo != nil) {
        AVMutableCompositionTrack *pAVMutableCompositionTrack = [pAVMutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [pAVMutableCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, trimDuration) ofTrack:pAVAssetTrackVideo atTime:kCMTimeZero error:&error];
    }
    if (pAVAssetTrackAudio != nil) {
        AVMutableCompositionTrack *pAVMutableCompositionTrack = [pAVMutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [pAVMutableCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, trimDuration) ofTrack:pAVAssetTrackAudio atTime:kCMTimeZero error:&error];
    }
    
   
    
    
    
    NSLog(@"%lf",duration);
    
    imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:set];
    
    CMTime actualTime;
    
    CGImageRef img = [imageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(20, 600) actualTime:&actualTime error:&error];
    

    
    int actualFramesNeeded = 0;
    if (duration <= 5) {
        actualFramesNeeded = 2;
    } else if (duration <= 10) {
        actualFramesNeeded = 8;
    } else if (duration <= 60) {
        actualFramesNeeded = duration / 2;
    } else if (duration <= 120) {
        actualFramesNeeded = duration / 3;
    } else {
        actualFramesNeeded = duration / 5;
    }
    set_duration = duration;
    
    CGFloat durationPerFrame = duration/actualFramesNeeded;
    
    _proviewImgItems = [[NSMutableArray alloc]init];
    
    Float64 start_time = 0;
    
    for (int i = 0; i< actualFramesNeeded; i++) {
        ProcessVideoItem *item = [[ProcessVideoItem alloc]init];
        item.size  = CGSizeMake(100, 100);
        item.time  = start_time+i*durationPerFrame;
        item.cTime = CMTimeMakeWithSeconds(item.time, 30);
        item.placeHodelImg = [[UIImage alloc]initWithCGImage:img];
        item.imageGenerator = imageGenerator;
        [_proviewImgItems addObject:item];
    }
    CGImageRelease(img);
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < 10 ; i++) {
        if (i < _proviewImgItems.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [array addObject:indexPath];
        }
    }
    [self LoadImageWithIndexPaths:array];
    
}

@end

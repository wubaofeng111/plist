//
//  AECollectionViewCell.h
//  RDVEUISDK
//
//  Created by wuxiaoxia on 2018/11/1.
//  Copyright © 2018年 北京锐动天地信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CutItemProtocol <NSObject>

-(void)CutItemWithCell:(UICollectionViewCell*_Nullable)cell WithItem1:(CGFloat)poi WithItem2:(CGFloat)item2;

@end


NS_ASSUME_NONNULL_BEGIN
@class ProcessVideoItem;

@interface AECollectionViewCell : UICollectionViewCell

@property(nonatomic,weak) id<CutItemProtocol> delegate;
    
@property(nonatomic, strong) UIImageView *coverIV;
@property(nonatomic, strong) UIView *tagView;
    
@property(nonatomic, strong) UILabel *nameLbl;

@property(nonatomic,weak) ProcessVideoItem *item;


-(void)setCorver:(CGFloat)xValue;

@end

NS_ASSUME_NONNULL_END

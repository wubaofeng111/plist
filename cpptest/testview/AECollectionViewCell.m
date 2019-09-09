//
//  AECollectionViewCell.m
//  RDVEUISDK
//
//  Created by apple on 2018/11/1.
//  Copyright © 2018年 北京锐动天地信息技术有限公司. All rights reserved.
//

#import "AECollectionViewCell.h"
#import "ProcessVideoViewController.h"

@implementation AECollectionViewCell
@synthesize delegate;

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.item.cell = nil;
    self.item = nil;
    self.tagView.frame = CGRectZero;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        self.backgroundColor = [UIColor whiteColor];
        _coverIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 35)];
        
        self.clipsToBounds = YES;
        _coverIV.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_coverIV];
        
        
        
        
        _nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, _coverIV.bounds.size.height, frame.size.width - 20, 35)];
        
        [self addSubview:_nameLbl];
        
        _tagView = [[UIView alloc]init];
        _tagView.backgroundColor = [UIColor orangeColor];
        [self addSubview:_tagView];
        
        
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(LongPress:)];
        [self addGestureRecognizer:press];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _coverIV.frame = self.bounds;
}


-(void)LongPress:(UILongPressGestureRecognizer*)press
{
    switch (press.state) {
        case UIGestureRecognizerStateBegan:
        {
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint pt = [press locationInView:self];
            CGFloat width = self.bounds.size.width;
            CGFloat it1 = pt.x/width;
            CGFloat it2 = 1-it1;
            [delegate CutItemWithCell:self WithItem1:it1 WithItem2:it2];
        }
            break;
            
        default:
            break;
    }
}


-(void)setCorver:(CGFloat)xValue
{
    if (_tagView.frame.size.width == 0) {
        _tagView.frame = CGRectMake(xValue, 0, 1, self.frame.size.height);
    }else{
        _tagView.frame = CGRectMake(_tagView.frame.origin.x, 0, xValue-_tagView.frame.origin.x, self.frame.size.height);
    }
    
    
}

@end

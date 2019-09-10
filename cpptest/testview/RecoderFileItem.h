//
//  RecoderFileItem.h
//  testview
//
//  Created by friday on 2019/9/10.
//  Copyright © 2019 friday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AECollectionViewCell.h"


NS_ASSUME_NONNULL_BEGIN

@interface RecoderFileItem : NSObject
@property(nonatomic,assign)CGFloat      startPoint;
@property(nonatomic,assign)CGFloat      endPoint;
@property(nonatomic,retain)NSIndexPath *startIndex;
@property(nonatomic,retain)NSIndexPath *curentIndex;
@property(nonatomic,retain)NSIndexPath *endIndex;


@property(nonatomic,retain)AECollectionViewCell *startCell;
@property(nonatomic,retain)AECollectionViewCell *curentCell;
@property(nonatomic,retain)AECollectionViewCell *endCell;
@end

NS_ASSUME_NONNULL_END

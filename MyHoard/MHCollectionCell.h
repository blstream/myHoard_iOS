//
//  MHCollectionCell.h
//  MyHoard
//
//  Created by Kacper Tłusty on 11.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHBadgeView.h"

@interface MHCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *collectionTitle;

@property (weak, nonatomic) IBOutlet MHBadgeView *badgeView;

@end

//
//  MHCollectionDetailsCell.h
//  MyHoard
//
//  Created by Kacper Tłusty on 24.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHCollectionDetailsCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UILabel *itemComment;
@property (weak, nonatomic) IBOutlet UIImageView *mediaView;
@property (weak, nonatomic) IBOutlet UIImageView *itemLocalization;


@end

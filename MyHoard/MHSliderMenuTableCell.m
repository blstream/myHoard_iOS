//
//  MHSliderMenuTableCell.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 11/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHSliderMenuTableCell.h"

@interface MHSliderMenuTableCell()

@property (nonatomic, strong) UIView* cellSeparatorView;

@end

@implementation MHSliderMenuTableCell

- (UIView *) cellSeparatorView {
    
    if (_separatorVisible) {
        _cellSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(12, self.bounds.size.height - 1, self.bounds.size.width - 12, 0.5)];
        _cellSeparatorView.backgroundColor = [UIColor blackColor];
    }
    return _cellSeparatorView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self addSubview:self.cellSeparatorView];
}

- (void)setSeparatorVisible:(BOOL)separatorVisible {
    if (separatorVisible) {
        _cellSeparatorView.hidden = NO;
    }else {
        _cellSeparatorView.hidden = YES;
    }
}

@end

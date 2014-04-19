//
//  MHItemDetailsViewController.m
//  MyHoard
//
//  Created by Kacper Tłusty on 13.04.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHItemDetailsViewController.h"
#import "MHImageCache.h"

#define BOTTOM_VIEW_COLLAPSED_HEIGHT 90

@interface MHItemDetailsViewController () <UIGestureRecognizerDelegate>
{
    BOOL _bottomViewExpanded;
}

@end

@implementation MHItemDetailsViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    _bottomViewExpanded = NO;
    
    _bottomView.backgroundColor = [UIColor collectionThumbnailOutlineColor];
    _bottomView.alpha = 0.6f;
    
    _itemCommentLabel.text = _item.objDescription;
    _itemCommentLabel.textColor = [UIColor tagFrontColor];
    
    _itemTitleLabel.text = _item.objName;
    _itemTitleLabel.textColor = [UIColor collectionNameFrontColor];
    for(MHMedia *media in _item.media) {
        _frontImage.image = [[MHImageCache sharedInstance] imageForKey:media.objKey];
        break; //just read first item
    }
    _itemTitle.title = _item.objName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)expandBottomView {
    [UIView animateWithDuration:0.3 animations:^{
        [_bottomView setFrame:CGRectMake(_bottomView.frame.origin.x, self.view.frame.size.height - _bottomView.frame.size.height, _bottomView.frame.size.width, _bottomView.frame.size.height)];
        [_dragTopButton setImage:[UIImage imageNamed:@"down_g"] forState:UIControlStateNormal];
        _bottomViewExpanded = YES;
    }];
}

- (void)collapseBottomView {
    [UIView animateWithDuration:0.3 animations:^{
        [_bottomView setFrame:CGRectMake(_bottomView.frame.origin.x, self.view.frame.size.height - BOTTOM_VIEW_COLLAPSED_HEIGHT, _bottomView.frame.size.width, _bottomView.frame.size.height)];
        [_dragTopButton setImage:[UIImage imageNamed:@"up_g"] forState:UIControlStateNormal];
        _bottomViewExpanded = NO;
    }];
}

- (IBAction)expandBottomViewButtonPressed:(id)sender
{
    if (_bottomViewExpanded) {
        [self collapseBottomView];
    } else {
        [self expandBottomView];
    }
}

- (IBAction)panGesture:(UIPanGestureRecognizer *)gesture;
{
    UIView *piece = _bottomView;
    
    CGFloat top = self.view.frame.size.height - _bottomView.frame.size.height;
    CGFloat bottom = self.view.frame.size.height - BOTTOM_VIEW_COLLAPSED_HEIGHT;
    
    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:[piece superview]];
        [piece setCenter:CGPointMake([piece center].x, [piece center].y + translation.y)];
		if (piece.frame.origin.y < top) {
			[piece setFrame:CGRectMake(piece.frame.origin.x, top, piece.frame.size.width, piece.frame.size.height)];
		}
		if (piece.frame.origin.y > bottom) {
			[piece setFrame:CGRectMake(piece.frame.origin.x, bottom, piece.frame.size.width, piece.frame.size.height)];
		}
        [gesture setTranslation:CGPointZero inView:[piece superview]];
		
    } else if ([gesture state] == UIGestureRecognizerStateEnded) {
        CGFloat middle = (bottom - top) / 2.0;
		if (_bottomView.frame.origin.y > (top + middle)) {
			[self collapseBottomView];
		} else {
			[self expandBottomView];
		}
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

@end

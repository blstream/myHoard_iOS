//
//  MHEditAccountViewController.h
//  MyHoard
//
//  Created by user on 04/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHBaseViewController.h"
#import "UIActionSheet+ButtonState.h"

@interface MHEditAccountViewController : MHBaseViewController <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *editPictureButton;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *passwordBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *lineOne;
@property (weak, nonatomic) IBOutlet UILabel *lineTwo;

- (IBAction)editPictureMenu:(id)sender;

@end
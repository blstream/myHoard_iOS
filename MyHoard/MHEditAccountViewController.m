//
//  MHEditAccountViewController.m
//  MyHoard
//
//  Created by user on 04/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHEditAccountViewController.h"

@interface MHEditAccountViewController ()

@end

@implementation MHEditAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.disableMHHamburger = YES;
    
    [self profilePictureViewShape];
    _backgroundView.backgroundColor = [UIColor lighterGray];
    
    _loginLabel.textColor = [UIColor collectionNameFrontColor];
    _emailLabel.textColor = [UIColor collectionNameFrontColor];
    [_editPictureButton setTitleColor:[UIColor collectionNameFrontColor] forState:UIControlStateSelected];
    [_editPictureButton setTitleColor:[UIColor collectionNameFrontColor] forState:UIControlStateNormal];
    
    _passwordLabel.textColor = [UIColor lightGrayColor];
    _passwordLabel.backgroundColor = [UIColor appBackgroundColor];
    _passwordBackgroundView.backgroundColor = [UIColor lighterGray];
    _saveButton.layer.cornerRadius = 17.0;
    [_changePasswordButton setTitleColor:[UIColor collectionNameFrontColor] forState:UIControlStateSelected];
    [_changePasswordButton setTitleColor:[UIColor collectionNameFrontColor] forState:UIControlStateNormal];
    
    _lineOne.backgroundColor = [UIColor lightGrayColor];
    _lineTwo.backgroundColor = [UIColor lightGrayColor];
}

- (void)profilePictureViewShape {
    
    _profilePicture.layer.backgroundColor=[[UIColor clearColor] CGColor];
    _profilePicture.layer.cornerRadius = 30.0;
    _profilePicture.layer.borderWidth = 2.0;
    _profilePicture.layer.masksToBounds = YES;
    _profilePicture.layer.borderColor=[[UIColor collectionNameFrontColor] CGColor];
    _profilePicture.image = [UIImage imageNamed:@"profile.png"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)editPictureMenu:(id)sender {
    
    UIActionSheet *alert = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete photo", @"Take a photo", @"Choose from library", @"Import from facebook", nil];
    [alert showInView:self.view];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;

            [button setTitleColor:[UIColor collectionNameFrontColor] forState:UIControlStateHighlighted];
            [button setTitleColor:[UIColor collectionNameFrontColor] forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor blackColor]];
        }
        
        if ([subview isKindOfClass:[UIView class]]) {
            UIView *backgroundView = (UIView *)subview;
            backgroundView.backgroundColor = [UIColor blackColor];
        }
    }
}
@end
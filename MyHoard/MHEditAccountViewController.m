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

    [self profilePictureViewShape];
    _backgroundView.backgroundColor = [UIColor lighterGray];
    
    [self setLabelTitle];
    
    _loginLabel.textColor = [UIColor collectionNameFrontColor];
    _emailLabel.textColor = [UIColor collectionNameFrontColor];
    [_editPictureButton setTitleColor:[UIColor collectionNameFrontColor] forState:UIControlStateSelected];
    [_editPictureButton setTitleColor:[UIColor collectionNameFrontColor] forState:UIControlStateNormal];
    
    _passwordtextField.textColor = [UIColor lightGrayColor];
    _passwordtextField.backgroundColor = [UIColor appBackgroundColor];
    
    _passwordtextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor darkerYellow]}];
    
    _passwordtextField.delegate = self;

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
    
    [self refreshImageData];
}

- (void)refreshImageData {
    
    NSString* imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/libraryProfilePhoto.png"];
    
    if (![imagePath length]) {
        _profilePicture.image = [UIImage imageNamed:@"profile.png"];
    }else {
        _profilePicture.image = [UIImage imageWithContentsOfFile:imagePath];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self refreshImageData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLabelTitle {
    
    [[MHAPI getInstance]readUserWithCompletionBlock:^(MHUserProfile *object, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:error.localizedDescription
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
            [alert show];
        }else {
            _loginLabel.text = object.username;
            _emailLabel.text = object.email;
        }
    }];
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
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [alert setButton:1 toState:NO];
    }
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

-(void)actionSheet:(UIActionSheet *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex){
        case 0:
            [self deletePhoto];
            break;
        case 1:
            [self performSegueWithIdentifier:@"ImagePickerSegue" sender:nil];
            break;
        case 2:
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case 3:
            break;
    }
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}


#pragma mark image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    NSData* imageData = UIImagePNGRepresentation(image);
    NSString* imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/libraryProfilePhoto.png"];
    [imageData writeToFile:imagePath atomically:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        _profilePicture.image = image;
    }];
}

- (IBAction)saveIt:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
}

- (void)deletePhoto {
    
    NSFileManager *mgr = [[NSFileManager alloc]init];
    
    NSString* imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/libraryProfilePhoto.png"];
    
    NSError *error = nil;
    
    if ([mgr fileExistsAtPath:imagePath]) {
        [mgr removeItemAtPath:imagePath error:&error];
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"No such file exist"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            
            [alert show];

        }else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Success"
                                  message:@"Picture deleted"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            
            [alert show];
            
            [self refreshImageData];
        }
    }
    
    
    
}

@end

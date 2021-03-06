//
//  MHAccountViewController.m
//  MyHoard
//
//  Created by user on 04/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHAccountViewController.h"

@interface MHAccountViewController ()

@end

@implementation MHAccountViewController

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
    
    self.navigationItem.backBarButtonItem = nil;
    
    [self loginLabelTitle];
    
    [self profilePictureViewShape];
    _loginLabel.textColor = [UIColor collectionNameFrontColor];
    _collectionsLabel.textColor = [UIColor collectionNameFrontColor];
    _photosLabel.textColor = [UIColor collectionNameFrontColor];
    _commentaryLabel.textColor = [UIColor lightGrayColor];
    _lineOne.backgroundColor = [UIColor lightGrayColor];
    _lineTwo.backgroundColor = [UIColor lightGrayColor];
    
    _numberOfCollections.layer.cornerRadius = 22.0;
    _numberOfPhotos.layer.cornerRadius = 22.0;

    [self badgeLayoutPositioning];
}

- (void)profilePictureViewShape {
    
    _profilePictureView.layer.backgroundColor=[[UIColor clearColor] CGColor];
    _profilePictureView.layer.cornerRadius = 75;
    _profilePictureView.layer.borderWidth = 2.0;
    _profilePictureView.layer.masksToBounds = YES;
    _profilePictureView.layer.borderColor=[[UIColor badgeBackgroundColor] CGColor];
    
    [self refreshImageData];
    
    [_profilePictureView layoutIfNeeded];
    [_profilePictureView setNeedsDisplay];
}

- (void)refreshImageData {
    
    if ([self retrieveProfilePictureFromCache]) {
        _profilePictureView.image = [self retrieveProfilePictureFromCache];
    }else {
        _profilePictureView.image = [UIImage imageNamed:@"profile.png"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self refreshImageData];
    [self loginLabelTitle];
}

- (NSInteger)collectionsNumber {
    
    NSArray *array = [MHDatabaseManager allCollections];
    return [array count];
}

- (NSInteger)photosNumber {
    
    NSArray *array = [MHDatabaseManager allCollections];
    NSInteger numberOfPhotos = 0;
    
    for (MHCollection *eachCollection in array) {
        for (MHItem *item in eachCollection.items) {
            numberOfPhotos += item.media.count;
        }
    }
    
    return numberOfPhotos;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loginLabelTitle {
    
    [[MHAPI getInstance]readUserWithCompletionBlock:^(MHUserProfile *object, NSError *error) {
        if (!error) {
            if (object.username) {
                _loginLabel.text = object.username;
            }else {
                NSArray *sub = [object.email componentsSeparatedByString:@"@"];
                NSString *substring = [sub objectAtIndex:0];
                _loginLabel.text = substring;
            }
        }else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            
            [alert show];
        }
    }];
}

- (void)badgeLayoutPositioning {
    
    if (![self collectionsNumber]) {
        _numberOfCollections.badgeValue = @0;
    }else {
        _numberOfCollections.badgeValue = [NSNumber numberWithInteger:[self collectionsNumber]];
        [_numberOfCollections layoutIfNeeded];
    }
    
    if (![self photosNumber]) {
        _numberOfPhotos.badgeValue = @0;
    }else {
        _numberOfPhotos.badgeValue = [NSNumber numberWithInteger:[self photosNumber]];
        [_numberOfPhotos layoutIfNeeded];
    }
}

- (UIImage *)retrieveProfilePictureFromCache {
    
    NSString* imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[MHAPI getInstance].userId];
    return [UIImage imageWithContentsOfFile:imagePath];
}

@end

//
//  MHBaseViewController.m
//  MyHoard
//
//  Created by Grzegorz Pawłowicz on 12.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHBaseViewController.h"
#import "UIColor+customColors.h"

@interface MHBaseViewController () <MHDropDownMenuDelegate, MHDropDownMenuDataSource>

@end

@implementation MHBaseViewController


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
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor navigationBarBackgroundColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    self.view.backgroundColor = [UIColor appBackgroundColor];
    
    if ([self enableMHLogo]) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    };
    
    if ([self hideNavigationBar]) {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
    }
    else{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    };
    
    self.menu.dataSource = self;
    self.menu.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self numberOfItemsInDropDownMenu:nil]) {
        self.menuButtonVisible = YES;
    } else {
        self.menuButtonVisible = NO;
    }
}

-(void)setEnableMHLogo:(BOOL)enableMHLogo{
    _enableMHLogo = enableMHLogo;
    if (enableMHLogo) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    };
    
}

-(void)setHideNavigationBar:(BOOL)hideNavigationBar{
    _hideNavigationBar = hideNavigationBar;
    if (hideNavigationBar) {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma MHDropDownMenu

- (NSInteger)numberOfItemsInDropDownMenu:(MHDropDownMenu *)menu {
    return 0;
}

- (UIColor*)backgroundColorInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index {
    return [UIColor blackColor];
}

- (UIColor *)textColorInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index{
    return [UIColor navigationBarBackgroundColor];
}

@end

//
//  MHAddCollectionViewController.h
//  MyHoard
//
//  Created by Konrad Gnoinski on 12/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHAddCollectionViewController : MHBaseViewController<UITextFieldDelegate,UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *nameBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *tagsBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *descriptionBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *questionBackgroundView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *tagsTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (nonatomic) NSArray *items;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) NSMutableDictionary *myDataSource;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeTitleLAbel;
- (IBAction)typeButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *pickerHidingView;
- (IBAction)pickerCancel:(id)sender;
- (IBAction)pickerSave:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *pickerCancelColor;
@property (weak, nonatomic) IBOutlet UIButton *pickerSaveColor;

- (IBAction)cancel:(id)sender;
- (IBAction)add:(id)sender;


@end

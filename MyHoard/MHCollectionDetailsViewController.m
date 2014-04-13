//
//  MHCollectionDetailsViewController.m
//  MyHoard
//
//  Created by user on 2/16/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//
#import "MHCollectionDetailsViewController.h"
#import "UIImage+Gallery.h"
#import "MHItemDetailsViewController.h"


@implementation MHCollectionDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.menuButtonImage = [UIImage imageNamed:@"plus"];
    self.selectedMenuButtonImage = [UIImage imageNamed:@"cancel"];

    self.view.backgroundColor = [UIColor lighterGray];
    
    _collectionView.backgroundColor = [UIColor lighterGray];
    self.collectionName.title = _collection.objName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionVIew

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _collection.items.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    MHCollectionDetailsCell *cell = (MHCollectionDetailsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MHItemCell" forIndexPath:indexPath];
    
    MHItem* object = [_collection.items.allObjects objectAtIndex:indexPath.row];
    
    cell.itemTitle.textColor = [UIColor collectionNameFrontColor];
    cell.itemComment.textColor = [UIColor appBackgroundColor];
    cell.backgroundColor = [UIColor blackColor];
    cell.mediaView.backgroundColor = [UIColor darkerGray];
    
    [self configureCell:cell withItem:object];
    
    return cell;
}


- (void)configureCell:(MHCollectionDetailsCell *)cell withItem:(MHItem *)item
{
    cell.itemComment.text = item.objDescription;
    cell.itemTitle.text = item.objName;

    for(MHMedia *media in item.media) {
        [UIImage thumbnailForAssetPath:media.objLocalPath completion:^(UIImage *image) {
            cell.mediaView.image = image;
        }];
        break; //just read first item
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = [self collectionView:_collectionView numberOfItemsInSection:[self numberOfSectionsInCollectionView:_collectionView]];
    
    if (count) {
        MHItem  *object = [_collection.items.allObjects  objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"ShowItemDetails" sender:object];
    }
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowItemDetails"]) {
        MHItemDetailsViewController * vc = [segue destinationViewController];
        vc.item = sender;
    }
}

#pragma mark - Collection header configure

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        MHCollectionDetailsHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MHItemViewHeader" forIndexPath:indexPath];

        headerView.backgroundColor = [UIColor darkerGray];
        headerView.collectionTitle.textColor = [UIColor collectionNameFrontColor];
        headerView.collectionTags.textColor = [UIColor whiteColor];

        headerView.collectionTitle.text = _collection.objDescription.length ? _collection.objDescription : _collection.objName;
        
        for (NSString *tag in _collection.objTags) {
            headerView.collectionTags.text = [NSString stringWithFormat:@"%@#%@ ", headerView.collectionTags.text, tag];
        }
        
        reusableview = headerView;
    }
    
    
    return reusableview;
}

#pragma mark MHDropDownMenu

- (NSInteger)numberOfItemsInDropDownMenu:(MHDropDownMenu *)menu {
    return 1;
}

- (NSString*)titleInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return [NSString stringWithFormat:@"Add item to '%@'", _collection.objName];
            break;
        default:
            return @"unused menu item";
    }
}

- (void)dropDownMenu:(MHDropDownMenu*)menu didSelectItemAtIndex:(NSUInteger)index {
    if (index == 0) {
        
    } else {
        NSLog(@"Unknown menu item %lu selected:", (unsigned long)index);
    }
    
}


@end
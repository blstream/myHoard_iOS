//
//  MHCollectionViewController.m
//  MyHoard
//
//  Created by Kacper Tłusty on 11.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHCollectionViewController.h"
#import "MHItemViewController.h"
#import "UIImage+Gallery.h"
#import "MHMedia.h"

typedef NS_ENUM(NSInteger, CollectionSortMode) {
    CollectionSortModeByName = 0,
    CollectionSortModeByDate
};

@interface MHCollectionViewController ()

@property (nonatomic, strong) MHBadgeView *badge;
@property (nonatomic, assign) CollectionSortMode sortMode;

-(void)resetIdleTimer;
-(void)idleTimerExceeded;

@end

@implementation MHCollectionViewController
{
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    NSTimer *timeToChangeCollection;
    MHCollectionCell *animatingCell;
}
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
    [self setEnableMHLogo:YES];
    // Do any additional setup after loading the view, typically from a nib.

    self.menuButtonImage = [UIImage imageNamed:@"plus"];
    self.selectedMenuButtonImage = [UIImage imageNamed:@"cancel"];
    
    self.title = @"";
    
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    animatingCell = nil;
    
    self.collectionView.backgroundColor = [UIColor appBackgroundColor];
    self.sortMode = CollectionSortModeByDate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionVIew
    
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = [self numberOfCollectionsInDatabaseForSection:section];
    if (count == 0) { //add one dummy element with +
        count = 1;
    }
    return count;
}
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MHCollectionCell *cell = (MHCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MHCollectionCell" forIndexPath:indexPath];
    
    cell.collectionTitle.textColor = [UIColor collectionNameFrontColor];
    cell.kenBurnsView.backgroundColor = [UIColor darkerGray];
    cell.tagsView.backgroundColor = [UIColor clearColor];

    if ([self numberOfCollectionsInDatabaseForSection:indexPath.section] == 0) { //special case for + element
        cell.collectionTitle.text = @"Name";
        cell.badgeView.hidden = YES;
        cell.tagsView.tagList = @[@"Tags"];
        cell.plusSignImageView.hidden = NO;
    } else {
        MHCollection *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
#pragma mark - cell setup
        
        cell.collectionTitle.text = object.objName;
        
        if ([object.objItemsNumber isEqualToNumber:@0]) {
            cell.badgeView.hidden = YES;
        }else {
            cell.badgeView.badgeValue = object.objItemsNumber;
        }
        
        cell.tagsView.tagList = object.objTags;
        cell.plusSignImageView.hidden = YES;
        
        [self cellConfiguration:cell withCoreDataObjectId:object.objId];
    }
    
    return cell;
}

#pragma mark - cell configuration with images

- (void)cellConfiguration:(MHCollectionCell *)cell withCoreDataObjectId:(NSString *)objectId {
    
    NSArray *items = [MHDatabaseManager getAllItemsForCollectionWithObjId:objectId];
    
    [cell.kenBurnsView removeAllImages];
    
#warning - select 5 random images if more than 5!
    for (MHItem *item in items) {
        for(MHMedia* media in item.media) {
            [UIImage thumbnailForAssetPath:media.objLocalPath completion:^(UIImage *image) {
                [cell.kenBurnsView addImage:image];
            }];
        }
    }
}

#pragma mark - picking random images for kenburns animation

- (NSMutableArray *)animateWithRandomImages:(NSMutableArray *)imagesArray {
    
    NSMutableArray *randomImages = [[NSMutableArray alloc]init];
    int randomCount = 5;
    
    if ([imagesArray count] >= randomCount) {
        while (randomCount > 0) {
            UIImage *randomImage = [imagesArray objectAtIndex:arc4random() % [imagesArray count]];
            if (![randomImages containsObject:randomImage]) {
                [randomImages addObject:randomImage];
                randomCount--;
            }
        }
    }
    
    return randomImages;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = [self numberOfCollectionsInDatabaseForSection:indexPath.section];

    if (count) {
        MHCollection *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"ShowItemsSegue" sender:object];
    } else {
        //special case for empty collection list - add new collection
        [self performSegueWithIdentifier:@"AddCollectionSegue" sender:nil];
    }
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MHItemViewController * vc = [segue destinationViewController];
    if ([segue.identifier isEqualToString:@"ShowItemsSegue"]) {
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        vc.collection = [self.fetchedResultsController objectAtIndexPath:indexPaths[0]];

    }
}

#pragma mark - Fetched results controller
    
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
    return _fetchedResultsController;
    }

    if (_sortMode == CollectionSortModeByDate) {
        _fetchedResultsController = [self sortByDate];
    } else {
        _fetchedResultsController = [self sortByName];
    }
    _fetchedResultsController.delegate = self;

    return _fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSMutableDictionary *change = [NSMutableDictionary new];
        
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
        }
        
    [_sectionChanges addObject:change];
}
    
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}
    
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([_sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
        
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
            [self.collectionView reloadData];
                
        } else {
            
            [self.collectionView performBatchUpdates:^{
                    
                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                            
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type) {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
        
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}
    
- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in self->_objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
        
    return shouldReload;
}

-(void)sendEvent:(UIEvent *)event
{
    [self resetIdleTimer];
}

-(void)resetIdleTimer
{
    [self stopAnimationTimer];
    timeToChangeCollection = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(idleTimerExceeded) userInfo:nil repeats:NO];

}

-(void)idleTimerExceeded
{
    if (animatingCell != nil) {
        [animatingCell.kenBurnsView stopAnimation];
    }
    
    NSArray *visibleCells = [self.collectionView indexPathsForVisibleItems];
    NSNumber *randomCell = [NSNumber numberWithUnsignedLong:(rand() % (visibleCells.count - 1))];
    
    NSIndexPath *cellPath = [NSIndexPath indexPathWithIndex:[randomCell unsignedIntegerValue]];
    
    MHCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"MHCollectionCell" forIndexPath:cellPath];
    [self.collectionView scrollToItemAtIndexPath:cellPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    //animating and showing cell, other things which needs to be implemented
    
    MHCollection *object = [self.fetchedResultsController objectAtIndexPath:cellPath];
    
    [self cellConfiguration:cell withCoreDataObjectId:object.objId];
    
    [cell.kenBurnsView startAnimation];
    
    animatingCell = cell;
    [self resetIdleTimer];
}

- (NSFetchedResultsController*) sortByName{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objName" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[MHCoreDataContext getInstance].managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    return frc;
}

- (NSFetchedResultsController*) sortByDate{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objCreatedDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[MHCoreDataContext getInstance].managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    return frc;
}

- (NSInteger)numberOfCollectionsInDatabaseForSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSInteger count = [sectionInfo numberOfObjects];
    return count;
}

- (void)setSortMode:(CollectionSortMode)sortMode {
    _sortMode = sortMode;
    _fetchedResultsController = nil;
    
    NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
}

- (void)stopAnimationTimer
{
    [timeToChangeCollection invalidate];
    timeToChangeCollection = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimationTimer];
}

#pragma mark MHDropDownMenu

- (NSInteger)numberOfItemsInDropDownMenu:(MHDropDownMenu *)menu {
    return 2;

}

- (NSString*)titleInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index {
    NSString *ret = @"";
    switch (index) {
        case 0:
            ret = @"Element";
            break;
        case 1:
            ret = @"Collection";
            break;
    }
    return ret;
}

- (UIImage *)imageInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index{
    switch (index) {
        case 0:
            return [UIImage imageNamed:@"elementImage.png"];
            break;
        case 1:
            return [UIImage imageNamed:@"collectionImage.png"];
            break;
        default:
            return nil;
    }
}

- (void)dropDownMenu:(MHDropDownMenu*)menu didSelectItemAtIndex:(NSUInteger)index {
    if (index == 0)
    {
        UIActionSheet *alert = [[UIActionSheet alloc]initWithTitle:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:@"Create without photo", @"Take a photo", @"Choose from library", nil];
        [alert showInView:self.view];
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            [alert setButton:1 toState:NO];
        }
    }
    
    else if (index == 1) {
        [self performSegueWithIdentifier:@"AddCollectionSegue" sender:nil];
    } else {
        NSLog(@"Unknown menu item %lu selected:", (unsigned long)index);
    }
}





-(void)actionSheet:(UIActionSheet *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex){
        case 0:
        [self performSegueWithIdentifier:@"AddItem2Segue" sender:nil];
            break;
        case 1:
        [self performSegueWithIdentifier:@"ImagePickerSegue" sender:nil];
            break;
        case 2:
            [self performSegueWithIdentifier:@"LibrarySegue" sender:nil];
            break;
    }
}


@end
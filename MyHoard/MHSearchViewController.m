//
//  MHSearchViewController.m
//  MyHoard
//
//  Created by user on 09/05/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHSearchViewController.h"
#import "MHDatabaseManager.h"
#import "MHCollection.h"
#import "MHCollectionDetailsViewController.h"
#import "UIImage+customImage.h"
#import "MHAPI.h"
#import "MHItemDetailsViewController.h"

#define HEADER_HEIGHT 44

NSString *const scopeTypeAll = @"All";
NSString *const scopeTypeTags = @"Tags";
NSString *const scopeTypeName = @"Name";
NSString *const scopeTypeDescription = @"Description";

@interface MHSearchViewController () {
    UIView* _headerView;
    NSString * _scope;
    BOOL _isVisible, _noResults;
}

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) NSFetchedResultsController *ifrc;
@property (nonatomic, strong) UITableViewCell *tableCell;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MHSearchViewController

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
    [self.navigationController setNavigationBarHidden:NO]; // so menu would be available for user
    _tableView.backgroundColor = [UIColor appBackgroundColor];
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor appBackgroundColor];
    
    _searchBar.barTintColor = [UIColor lighterGray];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor lightLoginAndRegistrationTextFieldTextColor]];
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor lightLoginAndRegistrationTextFieldTextColor]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor lightLoginAndRegistrationTextFieldTextColor]} forState:UIControlStateNormal];
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:[UIColor appBackgroundColor] size:CGSizeMake(320, 30)] forState:UIControlStateNormal];
    [_searchBar becomeFirstResponder];
    _searchBar.delegate = self;
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.view.frame.size.width, HEADER_HEIGHT)];
    _headerView.backgroundColor = [UIColor blackColor];
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"All", @"Tags", @"Name", @"Description", nil];
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    _segmentedControl.frame = CGRectMake(8, 8, _headerView.frame.size.width - 16, _headerView.frame.size.height - 16);
    _segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
    _segmentedControl.selectedSegmentIndex = 0;
    _segmentedControl.layer.borderColor = [UIColor lighterYellow].CGColor;
    _segmentedControl.layer.borderWidth = 1.0;
    _segmentedControl.layer.cornerRadius = 6.0;
    _segmentedControl.tintColor = [UIColor lighterYellow];
    _isVisible = YES;
    [self tableViewContentOffsetForSegmentedControl:_isVisible];
    
    [_segmentedControl addTarget:self
                          action:@selector(segmentedControlValueChanged:)
                forControlEvents:UIControlEventValueChanged];
    
    [_headerView addSubview:_segmentedControl];
    [self.view addSubview:_headerView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    _scope = scopeTypeAll;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view delegate methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        if (![[_frc fetchedObjects]count]) {
            return @"";
        }else {
            return @"Collections";
        }
    }else if (section == 1) {
        if (![[_ifrc fetchedObjects]count]) {
            return @"";
        }else {
            return @"Items";
        }
    }else {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger numberOfRows;
    id sectionInfo;
    NSUInteger ifrcSection = 0;
    
    if (![[_frc fetchedObjects]count] && ![[_ifrc fetchedObjects]count]) {
        _noResults = YES;
        return 0;
    }else {
        _noResults = NO;
        switch (section) {
            case 0:
                sectionInfo = [[_frc sections] objectAtIndex:section];
                numberOfRows = [sectionInfo numberOfObjects];
                break;
            case 1:
                sectionInfo = [[_ifrc sections] objectAtIndex:ifrcSection];
                numberOfRows = [sectionInfo numberOfObjects];
                break;
        }
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (tableView == self.searchDisplayController.searchResultsTableView && _noResults) {
        [tableView setSeparatorColor:[UIColor appBackgroundColor]];
    }else if (tableView == _tableView && _noResults) {
        [tableView setSeparatorColor:[UIColor appBackgroundColor]];
    }else if (tableView == self.searchDisplayController.searchResultsTableView || tableView == _tableView){
        [tableView setSeparatorColor:[UIColor appBackgroundColor]];
    }
    
    static NSString *cellId = @"searchCell";
    _tableCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (_tableCell == nil) {
        _tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    if ([[_frc fetchedObjects]count] && [[_ifrc fetchedObjects]count]) {
        if ([indexPath section] == 0) {
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                if (_frc) {
                    MHCollection *collection = [_frc objectAtIndexPath:indexPath];
                    _tableCell.textLabel.text = collection.objName;
                    _tableCell.userInteractionEnabled = YES;
                }else {
                    _tableCell.textLabel.text = @"";
                    _tableCell.userInteractionEnabled = NO;
                }
            }else {
                _tableCell.textLabel.text = @"Search for collection";
                _tableCell.textLabel.textAlignment = NSTextAlignmentCenter;
                _tableCell.userInteractionEnabled = NO;
            }
        }else if ([indexPath section] == 1) {
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                if (_ifrc) {
                    NSIndexPath *itemIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
                    MHItem *item = [_ifrc objectAtIndexPath:itemIndexPath];
                    _tableCell.textLabel.text = item.objName;
                    _tableCell.userInteractionEnabled = YES;
                }else {
                    _tableCell.textLabel.text = @"";
                    _tableCell.userInteractionEnabled = NO;
                }
            }else {
                _tableCell.textLabel.text = @"Search for item";
                _tableCell.textLabel.textAlignment = NSTextAlignmentCenter;
                _tableCell.userInteractionEnabled = NO;
            }
        }
    }else if ([[_frc fetchedObjects]count]){
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            if (_frc) {
                MHCollection *collection = [_frc objectAtIndexPath:indexPath];
                _tableCell.textLabel.text = collection.objName;
                _tableCell.userInteractionEnabled = YES;
            }else {
                _tableCell.textLabel.text = @"";
                _tableCell.userInteractionEnabled = NO;
            }
        }else {
            _tableCell.textLabel.text = @"Search for collection";
            _tableCell.textLabel.textAlignment = NSTextAlignmentCenter;
            _tableCell.userInteractionEnabled = NO;
        }
    }else if ([[_ifrc fetchedObjects]count]) {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            if (_ifrc) {
                NSIndexPath *itemIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
                MHItem *item = [_ifrc objectAtIndexPath:itemIndexPath];
                _tableCell.textLabel.text = item.objName;
                _tableCell.userInteractionEnabled = YES;
            }else {
                _tableCell.textLabel.text = @"";
                _tableCell.userInteractionEnabled = NO;
            }
        }else {
            _tableCell.textLabel.text = @"Search for item";
            _tableCell.textLabel.textAlignment = NSTextAlignmentCenter;
            _tableCell.userInteractionEnabled = NO;
        }
    }

    _tableCell.textLabel.textColor = [UIColor collectionNameFrontColor];
    _tableCell.backgroundColor = [UIColor appBackgroundColor];
    
    return _tableCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath section] == 0) {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            MHCollection *collection = [_frc objectAtIndexPath:indexPath];
            [self performSegueWithIdentifier:@"collectionDetails" sender:collection];
        }
    }else {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            NSIndexPath *itemIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            MHItem *item = [_ifrc objectAtIndexPath:itemIndexPath];
            [self performSegueWithIdentifier:@"itemDetails" sender:item];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

#pragma mark - segue

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"collectionDetails"]) {
        MHCollectionDetailsViewController * vc = [segue destinationViewController];
        vc.collection = sender;
    }else if ([segue.identifier isEqualToString:@"itemDetails"]) {
        MHItemDetailsViewController * vc = [segue destinationViewController];
        vc.item = sender;
    }
}

#pragma mark - search delegate methods

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    
    NSPredicate *predicate;

        if ([_scope isEqualToString:scopeTypeName]) {
            [self checkForActiveSessionAndSetPredicate:predicate withSearchText:searchText];
        }else if ([_scope isEqualToString:scopeTypeDescription]) {
            if ([MHAPI getInstance].userId) {
                predicate = [NSPredicate predicateWithFormat:@"SELF.objDescription matches[c] %@ AND SELF.objOwner == %@", searchText, [MHAPI getInstance].userId];
                [self collectionsFetchResultsControllerWithPredicate:predicate];
                [self itemsFetchResultsControllerWithPredicate:predicate];
            }else {
                predicate = [NSPredicate predicateWithFormat:@"SELF.objDescription matches[c] %@ AND SELF.objOwner == %@", searchText, nil];
                [self collectionsFetchResultsControllerWithPredicate:predicate];
                [self itemsFetchResultsControllerWithPredicate:predicate];
            }
        }else if ([_scope isEqualToString:scopeTypeTags]){
            [self checkForActiveSessionAndSetPredicateWhenTagsSearch:predicate withSearchText:searchText];
        }else {
            [self checkForActiveSessionAndSetPredicateWhenScopeTypeAll:predicate withSearchText:searchText];
        }
    
    if (searchText.length > 19) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Search fraze can be no longer than 20 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([searchBar.text length] + [text length] - range.length > 20) {
        [_searchBar resignFirstResponder];
        _frc = nil;
        _ifrc = nil;
    }
    return YES;
}

- (void)checkForActiveSessionAndSetPredicateWhenScopeTypeAll:(NSPredicate *)predicate withSearchText:(NSString *)searchText {
    if ([MHAPI getInstance].userId) {
        NSPredicate* p1 = [NSPredicate predicateWithFormat:@"SELF.objOwner == %@",[[MHAPI getInstance]userId]];
        NSPredicate* p2 = [NSPredicate predicateWithFormat:@"SUBQUERY(tags,$t,$t.tag ==[c] %@).@count > 0", searchText];
        NSPredicate *p3 = [NSPredicate predicateWithFormat:@"SELF.objName matches[c] %@", searchText];
        NSPredicate *p4 = [NSPredicate predicateWithFormat:@"SELF.objDescription matches[c] %@", searchText];
        NSPredicate* predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[p2, p3, p4]];
        NSPredicate *theAndPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[p1, predicate]];
        [self collectionsFetchResultsControllerWithPredicate:theAndPredicate];
        [self itemsFetchResultsControllerWithPredicate:theAndPredicate];
    }else {
        NSPredicate* p1 = [NSPredicate predicateWithFormat:@"SELF.objOwner == %@", nil];
        NSPredicate* p2 = [NSPredicate predicateWithFormat:@"SUBQUERY(tags,$t,$t.tag ==[c] %@).@count > 0", searchText];
        NSPredicate *p3 = [NSPredicate predicateWithFormat:@"SELF.objName matches[c] %@", searchText];
        NSPredicate *p4 = [NSPredicate predicateWithFormat:@"SELF.objDescription matches[c] %@", searchText];
        NSPredicate* predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[p2, p3, p4]];
        NSPredicate *theAndPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[p1, predicate]];
        [self collectionsFetchResultsControllerWithPredicate:theAndPredicate];
        [self itemsFetchResultsControllerWithPredicate:theAndPredicate];
    }
}

- (void)checkForActiveSessionAndSetPredicateWhenTagsSearch:(NSPredicate *)predicate withSearchText:(NSString *)searchText {
    if ([MHAPI getInstance].userId) {
        NSPredicate* p1 = [NSPredicate predicateWithFormat:@"objOwner == %@",[[MHAPI getInstance]userId]];
        NSPredicate* p2 = [NSPredicate predicateWithFormat:@"SUBQUERY(tags,$t,$t.tag ==[c] %@).@count > 0", searchText];
        NSPredicate* predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[p1, p2]];
        [self collectionsFetchResultsControllerWithPredicate:predicate];
        [self itemsFetchResultsControllerWithPredicate:predicate];
    }else {
        NSPredicate* p1 = [NSPredicate predicateWithFormat:@"objOwner == %@", nil];
        NSPredicate* p2 = [NSPredicate predicateWithFormat:@"SUBQUERY(tags,$t,$t.tag ==[c] %@).@count > 0", searchText];
        NSPredicate* predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[p1, p2]];
        [self collectionsFetchResultsControllerWithPredicate:predicate];
        [self itemsFetchResultsControllerWithPredicate:predicate];
    }
}

- (void)checkForActiveSessionAndSetPredicate:(NSPredicate *)predicate withSearchText:(NSString *)searchText {
    if ([MHAPI getInstance].userId) {
        predicate = [NSPredicate predicateWithFormat:@"SELF.objName matches[c] %@ AND SELF.objOwner == %@", searchText, [MHAPI getInstance].userId];
        [self collectionsFetchResultsControllerWithPredicate:predicate];
        [self itemsFetchResultsControllerWithPredicate:predicate];
    }else {
        predicate = [NSPredicate predicateWithFormat:@"SELF.objName matches[c] %@ AND SELF.objOwner == %@", searchText, nil];
        [self collectionsFetchResultsControllerWithPredicate:predicate];
        [self itemsFetchResultsControllerWithPredicate:predicate];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    if (searchString.length > 1) {
        [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    }
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - FRC

- (void)collectionsFetchResultsControllerWithPredicate:(NSPredicate *)predicate {
    NSError *error = nil;
    [[self fetchAllCollectionsWithPredicate:predicate]performFetch:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);
    }
}

- (void)itemsFetchResultsControllerWithPredicate:(NSPredicate *)predicate {
    NSError *error = nil;
    [[self fetchAllItemsWithPredicate:predicate]performFetch:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);
    }
}

- (NSFetchedResultsController *)fetchAllItemsWithPredicate:(NSPredicate *)predicate {
    
    if (_ifrc == nil) {
        [NSFetchedResultsController deleteCacheWithName:@"Root"];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHItem" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objName" ascending:YES selector:@selector(localizedStandardCompare:)];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        
        NSFetchedResultsController *fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[MHCoreDataContext getInstance].managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
        fetchResultsController.delegate = self;
        _ifrc = fetchResultsController;
        
    }else {
        [_ifrc.fetchRequest setPredicate:predicate];
        NSError *error = nil;
        [_ifrc performFetch:&error];
        if (error) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);
        }
    }
    
    return _ifrc;
}

- (NSFetchedResultsController *)fetchAllCollectionsWithPredicate:(NSPredicate *)predicate {
    
    if (_frc == nil) {
        [NSFetchedResultsController deleteCacheWithName:@"Root"];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objName" ascending:YES selector:@selector(localizedStandardCompare:)];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        [fetchRequest setFetchBatchSize:20];
        
        NSFetchedResultsController *fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[MHCoreDataContext getInstance].managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
        
        fetchResultsController.delegate = self;
        self.frc = fetchResultsController;
        
    }else {
        
        [_frc.fetchRequest setPredicate:predicate];
        NSError *error = nil;
        [_frc performFetch:&error];
        if (error) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);
        }
    }
    
    return _frc;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.searchDisplayController.searchResultsTableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.searchDisplayController.searchResultsTableView endUpdates];
}

//Sample code taken from NSFetchedResultsControllerDelegate Protocol Reference "Typical Use"
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.searchDisplayController.searchResultsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.searchDisplayController.searchResultsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


//Sample code taken from NSFetchedResultsControllerDelegate Protocol Reference "Typical Use"
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.searchDisplayController.searchResultsTableView;
	
    if (controller == _ifrc) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:1];
        if (newIndexPath) {
            newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:1];
        }
    }
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];

                break;
        }
    
}

#pragma mark segmented control

- (void)segmentedControlValueChanged:(UISegmentedControl *)sender {
    NSInteger index = [sender selectedSegmentIndex];
    switch (index) {
        case 0:
            _scope = scopeTypeAll;
            break;
        case 1:
            _scope = scopeTypeTags;
            break;
        case 2:
            _scope = scopeTypeName;
            break;
        case 3:
            _scope = scopeTypeDescription;
            break;
        default:
            _scope = scopeTypeAll;
            break;
    }
}

- (void)tableViewContentOffsetForSegmentedControl:(BOOL)isVisible {
    if (isVisible) {
        _tableView.frame = CGRectOffset(_tableView.frame, 0, 132);
    }
}

#pragma mark - search bar utility methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    
    [UIView animateWithDuration:0.1 animations:^{
        _headerView.frame = CGRectOffset(_headerView.frame, 0, -20);
    }];

    CGRect statusBarFrame =  [[UIApplication sharedApplication] statusBarFrame];
    [UIView animateWithDuration:0.25 animations:^{
        for (UIView *subview in self.view.subviews) {
            subview.transform = CGAffineTransformMakeTranslation(0, statusBarFrame.size.height + 20);
        }
    }];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    
    [UIView animateWithDuration:0.1 animations:^{
        _headerView.frame = CGRectOffset(_headerView.frame, 0, +20);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        for (UIView *subview in self.view.subviews) {
            subview.transform = CGAffineTransformIdentity;
        }
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _frc = nil;
    _ifrc = nil;
    [_tableView reloadData];
}

#pragma mark - keyboard observers

- (void)keyboardDidShow: (NSNotification *) notif{
    
    [UIView animateWithDuration:0.25 animations:^{
        _tableView.frame = CGRectOffset(_tableView.frame, 0, -20);
    }];
}

- (void)keyboardDidHide: (NSNotification *) notif{
    
    [UIView animateWithDuration:0.25 animations:^{
        _tableView.frame = CGRectOffset(_tableView.frame, 0, 0);
    }];
}



@end

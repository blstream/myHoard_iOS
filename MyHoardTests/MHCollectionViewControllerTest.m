//
//  MHCollectionViewControllerTest.m
//  MyHoard
//
//  Created by user on 2/24/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MHCollectionViewController.h"
#import "MHCollection.h"
#import "MHDatabaseManager.h"
#import "Kiwi.h"
#import "MHCoreDataContextForTests.h"

@interface MHCollectionViewControllerTest : XCTestCase

@end

@implementation MHCollectionViewControllerTest{
    
    UIStoryboard *storyboard;
    MHCollectionViewController *_vc;
}

static id partialMockForView() {
    
    MHCollectionViewController *viewController = [[MHCollectionViewController alloc]init];
    id mockViewController = [KWMock partialMockForObject:viewController];
    return mockViewController;
}

- (void)setUp
{
    [super setUp];
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MHCollectionViewController class])];
    [_vc view];
}

- (void)tearDown
{
    _vc = nil;
    storyboard = nil;
    [super tearDown];
}

- (void)testViewDidLoad {
    
    [_vc viewDidLoad];
    
    XCTAssertNotNil(_vc.fetchedResultsController, @"");
    
    [MHDatabaseManager insertCollectionWithObjId:@"testId" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
    
    MHCollection *fetchedCollection = [_vc.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    XCTAssertNotNil(fetchedCollection, @"");
    XCTAssertEqualObjects(fetchedCollection.objId, @"testId", @"");
    
    [MHDatabaseManager removeCollectionWithId:@"testId"];
}

- (void)testStoryboardShouldExist {
    
    XCTAssertNotNil(storyboard, @"");
}

- (void)testViewControllerShouldExist {
    
    XCTAssertNotNil(_vc, @"");
}


#pragma Outlets

- (void)testThatNavigationItemTitleExist {
    
    XCTAssertNotNil(_vc.navigationItem.title, @"");
}

- (void)testThatAddButtonExist {
    
    XCTAssertNotNil(_vc.navigationItem.rightBarButtonItem, @"");
}

@end

SPEC_BEGIN(newTest)

describe(@"MHCollectionViewController", ^{
    
    __block MHCoreDataContextForTests* mhc = nil;
    
    beforeEach(^{
        mhc = [MHCoreDataContextForTests new];
        [MHCoreDataContext stub:@selector(getInstance) andReturn:mhc];
    });
    
    afterEach(^{
        [mhc dropTestPersistentStore];
        mhc = nil;
    });
    
    it(@"Should return number of sections", ^{
        
        id mockFetchedResultsController = [KWMock mockForClass:[NSFetchedResultsController class]];
        [[mockFetchedResultsController stubAndReturn:@[[NSObject new]]]sections];
        
        id mockViewController = partialMockForView();
        [[mockViewController stubAndReturn:mockFetchedResultsController]fetchedResultsController];
        
        UITableView *tableView = [[UITableView alloc]init];
        id mockTableView = [KWMock partialMockForObject:tableView];
        [[mockTableView stubAndReturn:[KWValue valueWithInteger:1]]numberOfSectionsInTableView:mockTableView];
        
        NSInteger numberOfSections = [mockViewController numberOfSectionsInTableView:mockTableView];
        
        [[theValue(numberOfSections) should]equal:theValue(1)];
        
    });
    
    it(@"Should return number of rows in section", ^{
       
        NSInteger numberOfRows = 23;
        
        id mockSectionInfo = [KWMock mockForProtocol:@protocol(NSFetchedResultsSectionInfo)];
        [[mockSectionInfo stubAndReturn:[KWValue valueWithInteger:numberOfRows]]numberOfObjects];
        
        id mockFetchedResultsController = [KWMock mockForClass:[NSFetchedResultsController class]];
        [[mockFetchedResultsController stubAndReturn:@[mockSectionInfo]]sections];
        
        UITableView *tableView = [[UITableView alloc]init];
        id mockTableView = [KWMock partialMockForObject:tableView];
        [[mockTableView stubAndReturn:[KWValue valueWithInteger:numberOfRows]]numberOfRowsInSection:0];
        
        id mockViewController = partialMockForView();
        
        [[mockViewController stubAndReturn:mockFetchedResultsController] fetchedResultsController];
        
        NSInteger numberOfRowsInSection = [mockTableView numberOfRowsInSection:0];
        NSInteger numberORISFromMSI = [mockSectionInfo numberOfObjects];
        NSInteger numberOSIMFRC = [[mockFetchedResultsController sections] count];
        NSInteger numberORISFromMVC = [mockViewController numberOfSectionsInTableView:mockTableView];
        
        [[theValue(numberOfRowsInSection)should]equal:theValue(numberOfRows)];
        [[theValue(numberOfRows)should]equal:theValue(numberORISFromMSI)];
        [[theValue(numberOSIMFRC)should]equal:theValue(1)];
        [[theValue(numberORISFromMVC)should]equal:theValue(1)];
        
    });
    
    it(@"NSFetchResultsController should return object at index path", ^{
        
        [MHDatabaseManager insertCollectionWithObjId:@"testId" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objName" ascending:NO];
        
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSFetchedResultsController *rc = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:mhc.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
        
        NSError *error = nil;
        
        [rc performFetch:&error];
        
        MHCollection *collection = [rc objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        [[error should]beNil];
        [[collection should]beNonNil];
        [[collection.objName should]equal:@"name"];
        
        [MHDatabaseManager removeCollectionWithId:@"testId"];
        
    });
});

SPEC_END

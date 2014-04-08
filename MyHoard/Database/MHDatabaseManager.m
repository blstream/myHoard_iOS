//
//  MHDatabaseManager.m
//  MyHoard
//
//  Created by Karol Kogut on 14.02.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHDatabaseManager.h"

#import "MHCoreDataContext.h"
#import "MHCollection.h"
#import "MHItem.h"
#import "MHMedia.h"


@implementation MHDatabaseManager

#pragma mark - Collection
+ (void)insertCollectionWithObjName:(NSString*)objName
                     objDescription:(NSString*)objDescription
                            objTags:(NSArray*)objTags
                     objItemsNumber:(NSNumber*)objItemsNumber
                     objCreatedDate:(NSDate*)objCreatedDate
                    objModifiedDate:(NSDate*)objModifiedDate
                           objOwner:(NSString*)objOwner
{
    // mandatory fields
    if (!objName.length || !objCreatedDate)
    {
        NSLog(@"One of mandatory fields is not set: objName:%@, objCreatedDate:%@", objName, objCreatedDate);
        return;
    }

    MHCollection* collection = [NSEntityDescription insertNewObjectForEntityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    
    
    collection.objName = objName;
    collection.objCreatedDate = objCreatedDate;

    if (objDescription.length)
        collection.objDescription = objDescription;

    if (objTags.count)
        collection.objTags = objTags;

    if (objItemsNumber)
        collection.objItemsNumber = @0;

    if (objModifiedDate)
        collection.objModifiedDate = objModifiedDate;

    if (objOwner.length)
        collection.objOwner = objOwner;

    [[MHCoreDataContext getInstance] saveContext];
}

+ (MHCollection*)getCollectionWithObjId:(NSString*)objId
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext: [MHCoreDataContext getInstance].managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"objId = %@", objId]];
    NSError *error = nil;
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetch error:&error];
    if(error==nil){
        if([fetchedObjects count] == 1)
        {
            return [fetchedObjects objectAtIndex:0];
        }
    }
    NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
    return nil;
}
+ (NSArray*)getAllCollections
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setSortDescriptors:@[ [[NSSortDescriptor alloc] initWithKey: @"objName" ascending:YES] ]];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil)
        NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
    
    
    return fetchedObjects;
}

+ (void)removeCollectionWithId:(NSString*)objId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"objId==%@", objId]];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects && error==nil) {
        for (NSManagedObject *obj in fetchedObjects) {
            [[MHCoreDataContext getInstance].managedObjectContext deleteObject:obj];
        }
    }
    
    else {
        NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
    }
    
    [[MHCoreDataContext getInstance] saveContext];

}

+ (MHCollection*)getCollectionWithObjName:(NSString*)objName{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext: [MHCoreDataContext getInstance].managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"objName = %@", objName]];
    NSError *error = nil;
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetch error:&error];
    if(error==nil){
        if([fetchedObjects count] == 1)
        {
            return [fetchedObjects objectAtIndex:0];
        }
    }
    NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
    return nil;
}


#pragma mark - Item
+ (MHItem*)insertItemWithObjName:(NSString*)objName
                  objDescription:(NSString*)objDescription
                         objTags:(NSArray*)objTags
                     objLocation:(NSDictionary*)objLocation
                     objQuantity:(NSNumber*)objQuantity
                     objMediaIds:(NSArray*)objMediaIds
                  objCreatedDate:(NSDate*)objCreatedDate
                 objModifiedDate:(NSDate*)objModifiedDate
                 objCollectionId:(NSString*)objCollectionId
                        objOwner:(NSString*)objOwner
{
    
    //mandatory fields
    if (!objName || !objCreatedDate || !objCollectionId.length) {
        
        NSLog(@"One of mandatory fields is not set: objName:%@, objCreatedDate:%@, objCollectionId:%@", objName, objCreatedDate, objCollectionId);
        return nil;
    }
    
    //check if collection does exist
    if (![MHDatabaseManager getCollectionWithObjId:objCollectionId]){
        NSLog(@"Collection with Id: %@ does not exist! To add item create collection with specified Id", objCollectionId);
        return nil;
    }
    
    MHItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"MHItem" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    
    item.objName = objName;
    item.objCreatedDate = objCreatedDate;
    item.objCollectionId = objCollectionId;
    
    
    if (objDescription.length) {
        item.objDescription = objDescription;
    }
    
    if (objTags.count) {
        item.objTags = objTags;
    }
    
    if (objLocation.count) {
        item.objLocation = objLocation;
    }
    
    if (objQuantity) {
        item.objQuantity = objQuantity;
    }
    
    if (objMediaIds.count) {
        item.objMediaIds = objMediaIds;
    }
    
    if (objModifiedDate) {
        item.objModifiedDate = objModifiedDate;
    }
    
    if (objOwner.length) {
        item.objOwner = objOwner;
    }
    
    //Add item with objCollectionId to a specified collection
    [[MHDatabaseManager getCollectionWithObjId:objCollectionId] addItemsObject:item];
    [item setCollection:[MHDatabaseManager getCollectionWithObjId:objCollectionId]];
    
    int value = [[MHDatabaseManager getCollectionWithObjId:objCollectionId].objItemsNumber intValue];
    [MHDatabaseManager getCollectionWithObjId:objCollectionId].objItemsNumber = [NSNumber numberWithInt:value + 1];
    
    [[MHCoreDataContext getInstance] saveContext];
    
    return item;
}


+ (MHItem*)itemWithObjId:(NSString*)objId
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MHItem" inManagedObjectContext: [MHCoreDataContext getInstance].managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"objId = %@", objId]];
    NSError *error = nil;
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count] == 1)
    {
        MHItem *item = [fetchedObjects objectAtIndex:0];
        return item;
    }
    else
        return nil;
  }

+ (MHItem*)itemWithObjName:(NSString*)objName{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MHItem" inManagedObjectContext: [MHCoreDataContext getInstance].managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"objName = %@", objName]];
    NSError *error = nil;
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count] == 1)
    {
        MHItem *item = [fetchedObjects objectAtIndex:0];
        return item;
    }
    else
        return nil;
}

+ (NSArray*)getAllItemsForCollectionWithObjId:(NSString*)collectionObjId
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHItem" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"objCollectionId==%@", collectionObjId]];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil){
        NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
        return nil;
    }
    
    return fetchedObjects;
    
}

+ (void)removeItemWithObjId:(NSString*)objId
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHItem" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"objId==%@", objId]];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects != nil && error == nil) {
        for (NSManagedObject *object in fetchedObjects) {
            [[MHCoreDataContext getInstance].managedObjectContext deleteObject:object];
        }
    }else {
        NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
    }
    
    [[MHCoreDataContext getInstance] saveContext];
    
}

+ (void)removeAllItemForCollectionWithObjId:(NSString*)collectionObjId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHItem" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"objCollectionId==%@", collectionObjId]];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects != nil && error == nil) {
        for (NSManagedObject *object in fetchedObjects) {
            [[MHCoreDataContext getInstance].managedObjectContext deleteObject:object];
        }
    }else {
        NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
    }
    
    [[MHCoreDataContext getInstance] saveContext];
    
}

#pragma mark - Media
+ (void)insertMediaWithObjItem:(NSString*)objItem
                objCreatedDate:(NSDate*)objCreatedDate
                      objOwner:(NSString*)objOwner
                  objLocalPath:(NSString*)objLocalPath
                          item:(MHItem *)item
{
    // mandatory fields
    if (!objCreatedDate)
    {
        NSLog(@"One of mandatory fields is not set: objCreatedDate:%@", objCreatedDate);
        return;
    }
    
    MHMedia* media = [NSEntityDescription insertNewObjectForEntityForName:@"MHMedia" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
        
    media.objCreatedDate = objCreatedDate;

    media.item = item;
    
    if (objItem.length)
        media.objItem = objItem;
    
    if (objLocalPath.length)
        media.objLocalPath = objLocalPath;
    
    if (objOwner.length)
        media.objOwner = objOwner;
    
    [[MHCoreDataContext getInstance] saveContext];
}

+ (MHMedia*)mediaWithObjId:(NSString*)objId
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MHMedia" inManagedObjectContext: [MHCoreDataContext getInstance].managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"objId = %@", objId]];
    NSError *error = nil;
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetch error:&error];
    if(error==nil){
        if([fetchedObjects count] == 1)
        {
            return [fetchedObjects objectAtIndex:0];
        }
    }
    NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
    return nil;
}


+ (void)removeMediaWithObjId:(NSString *)objId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHMedia" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"objId==%@", objId]];
    NSError *error = nil;
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects != nil && error == nil)
    {
        for (NSManagedObject *objects in fetchedObjects)
        {
            [[MHCoreDataContext getInstance].managedObjectContext deleteObject:objects];
        }
    }
    else
    {
        NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
    }
    
    [[MHCoreDataContext getInstance] saveContext];
}

@end


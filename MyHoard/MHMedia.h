//
//  MHMedia.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 20/05/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MHItem;

@interface MHMedia : NSManagedObject

@property (nonatomic, retain) NSDate * objCreatedDate;
@property (nonatomic, retain) NSString * objId;
@property (nonatomic, retain) NSString * objKey;
@property (nonatomic, retain) NSString * objOwner;
@property (nonatomic, retain) NSString * objStatus;
@property (nonatomic, retain) MHItem *item;

@end

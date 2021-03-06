//
//  MHLocation.h
//  MyHoard
//
//  Created by Konrad Gnoinski on 01/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
typedef void (^MHLocationCompletionBlock)(NSArray* object);

@interface  MHLocation : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
}

@property (strong, readonly) CLLocation *currentLocation;

+ (MHLocation *)sharedInstance;
- (void)startGettingLocation;
- (void)stopGettingLocation;
- (void)geolocateWithCity:(NSString*) city
               withStreet:(NSString*) street
           withPostalCode:(NSString*) postal
          completionBlock:(MHLocationCompletionBlock)completionBlock;

@end


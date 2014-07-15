//
//  TAJLocationManager.h
//  Skene
//
//  Created by Timo Jääskeläinen on 13.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// Name constants for various notifications that MessageStore emits
// Emitted after a list of messages form a given parent was updated
extern NSString * const TAJUserLocationUpdated;

@interface TAJLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, readonly, strong) CLLocation *currentLocation;
@property (nonatomic, readonly) BOOL isTrackingLocation;

- (void)startTracking;
- (void)stopTracking;

@end

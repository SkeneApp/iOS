//
//  TAJLocationManager.m
//  Skene
//
//  Created by Timo Jääskeläinen on 10.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import "TAJLocationManager.h"


NSString *const TAJUserLocationUpdated = @"TAJUserLocationUpdated";

@interface TAJLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation TAJLocationManager

- (void)startTracking
{
    if (self.isTrackingLocation == NO) {
        [self.locationManager startUpdatingLocation];
        _isTrackingLocation = YES;
    }
}

- (void)stopTracking
{
    if (_locationManager) {
        [_locationManager stopUpdatingLocation];
        _locationManager = nil;
    }
    _isTrackingLocation = NO;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 10.0f;
        _locationManager.delegate = self;
        [_locationManager requestWhenInUseAuthorization];
    }
    return _locationManager;
}

- (NSString *)updateNotificationName
{
    return TAJUserLocationUpdated;
}

#pragma mark -- CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *lastLocation = [locations lastObject];
    _currentLocation = lastLocation;
    [self notifyOfNewLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)notifyOfNewLocation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:_currentLocation, @"location", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:TAJUserLocationUpdated object:self userInfo:userInfo];
    });
}

@end

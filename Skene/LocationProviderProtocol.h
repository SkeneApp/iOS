//
//  LocationProviderProtocol.h
//  Skene
//
//  Created by Timo Jääskeläinen on 16.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@protocol LocationProvider <NSObject>

@property (nonatomic, readonly, copy) NSString *updateNotificationName;

@property (nonatomic, readonly, strong) CLLocation *currentLocation;

@end
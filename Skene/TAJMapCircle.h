//
//  TAJMapCircle.h
//  Skene
//
//  Created by Timo Jääskeläinen on 13.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

// This class enapsulates MKCircle overlay to attach additional properties to it.
// Subclassing and extending MKCircle didn't work.

@interface TAJMapCircle : NSObject <MKOverlay>

typedef NS_ENUM(NSUInteger, TAJMapCircleType) {
    kTAJMapCircleTypeFeedLocation,
    kTAJMapCircleTypeMessage
};

@property (nonatomic, retain) MKCircle *circle;
@property (nonatomic) TAJMapCircleType type;
@property (nonatomic) double strokeWidth;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *strokeColor;

+ (instancetype)mapCircleOfType:(TAJMapCircleType)type withLocation:(CLLocationCoordinate2D)location andRadius:(CLLocationDistance)radiusMeters;

@end

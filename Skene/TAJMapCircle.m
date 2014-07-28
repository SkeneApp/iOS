//
//  TAJMapCircle.m
//  Skene
//
//  Created by Timo Jääskeläinen on 13.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import "TAJMapCircle.h"

#define FEED_COLOR greenColor
#define FEED_FILL_OPACITY 0.2
#define FEED_STROKE_OPACITY 0.7
#define FEED_STROKE_WIDTH 3

#define MESSAGE_COLOR redColor
#define MESSAGE_FILL_OPACITY 0.5
#define MESSAGE_STROKE_OPACITY 0.7
#define MESSAGE_STROKE_WIDTH 5

@implementation TAJMapCircle

+ (instancetype)mapCircleOfType:(TAJMapCircleType)type withLocation:(CLLocationCoordinate2D)location andRadius:(CLLocationDistance)radiusMeters
{
    TAJMapCircle *mapCircle = [[TAJMapCircle alloc] init];
    mapCircle.circle = [MKCircle circleWithCenterCoordinate:location radius:radiusMeters];
    mapCircle.type = type;
    switch (type) {
        case kTAJMapCircleTypeFeedLocation:
            mapCircle.fillColor = [[UIColor FEED_COLOR] colorWithAlphaComponent:FEED_FILL_OPACITY];
            mapCircle.strokeColor = [[UIColor FEED_COLOR] colorWithAlphaComponent:FEED_STROKE_OPACITY];
            mapCircle.strokeWidth = FEED_STROKE_WIDTH;
            break;
        case kTAJMapCircleTypeMessage:
            mapCircle.fillColor = [[UIColor MESSAGE_COLOR] colorWithAlphaComponent:MESSAGE_FILL_OPACITY];
            mapCircle.strokeColor = [[UIColor MESSAGE_COLOR] colorWithAlphaComponent:MESSAGE_STROKE_OPACITY];
            mapCircle.strokeWidth = MESSAGE_STROKE_WIDTH;
            break;
            
        default:
            break;
    }
    return mapCircle;
}

+ (instancetype)mapCircleOfType:(TAJMapCircleType)type WithCircle:(MKCircle *)circle
{
    TAJMapCircle *mapCircle = [[TAJMapCircle alloc] init];
    mapCircle.circle = circle;
    mapCircle.type = type;
    switch (type) {
        case kTAJMapCircleTypeFeedLocation:
            mapCircle.fillColor = [[UIColor FEED_COLOR] colorWithAlphaComponent:FEED_FILL_OPACITY];
            mapCircle.strokeColor = [[UIColor FEED_COLOR] colorWithAlphaComponent:FEED_STROKE_OPACITY];
            mapCircle.strokeWidth = FEED_STROKE_WIDTH;
            break;
        case kTAJMapCircleTypeMessage:
            mapCircle.fillColor = [[UIColor MESSAGE_COLOR] colorWithAlphaComponent:MESSAGE_FILL_OPACITY];
            mapCircle.strokeColor = [[UIColor MESSAGE_COLOR] colorWithAlphaComponent:MESSAGE_STROKE_OPACITY];
            mapCircle.strokeWidth = MESSAGE_STROKE_WIDTH;
            break;
            
        default:
            break;
    }
    return mapCircle;
}


#pragma mark MKOverlay
- (CLLocationCoordinate2D) coordinate {
    return [self.circle coordinate];
}

- (MKMapRect) boundingMapRect {
    return [self.circle boundingMapRect];
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
    return [self.circle intersectsMapRect:mapRect];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"(%f, %f)", self.circle.coordinate.latitude, self.circle.coordinate.longitude];
}

@end
//
//  TAJMapCircle.m
//  Skene
//
//  Created by Timo Jääskeläinen on 13.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import "TAJMapCircle.h"

@implementation TAJMapCircle

+ (instancetype)mapCircleWithCircle:(MKCircle *)circle
{
    TAJMapCircle *mapCircle = [[TAJMapCircle alloc] init];
    mapCircle.circle = circle;
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
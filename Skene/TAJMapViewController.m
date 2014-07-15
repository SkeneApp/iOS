//
//  TAJMapViewController.m
//  Skene
//
//  Created by Timo Jääskeläinen on 13.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import "TAJMapViewController.h"
#import <MapKit/MapKit.h>
#import "TAJMapCircle.h"
#import "TAJFeedViewController.h"

// The default radius from where to get the map data
#define DEFAULT_RADIUS 500
// The maximum number of map data items to fetch at once
#define MAP_DATA_ITEMS_LIMIT 50
// The radius of map data item in meters
#define MAP_DATA_ITEM_RADIUS 100
// The default zoom span in degrees (just approximate value)
#define DEFAULT_ZOOM_SPAN 0.03

@interface TAJMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *map;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) TAJMapCircle *feedCircle;
@property (nonatomic, strong) NSMutableArray *messageOverlays;
@property (nonatomic, strong) NSMutableArray *mapData;

@end

@implementation TAJMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapData = [NSMutableArray arrayWithCapacity:MAP_DATA_ITEMS_LIMIT];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    self.messageOverlays = [[NSMutableArray alloc] initWithCapacity: MAP_DATA_ITEMS_LIMIT];
    [self.map addGestureRecognizer:self.tapGestureRecognizer];
    self.map.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapDataUpdated:) name:TAJMessageStoreMapDataUpdated object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAJMessageStoreMapDataUpdated object:nil];
}

- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint touchPoint = [gestureRecognizer locationInView:self.map];
        CLLocationCoordinate2D tapCoordinate = [self.map convertPoint:touchPoint toCoordinateFromView:self.map];
        [self setFeedLocation:tapCoordinate andRadius:DEFAULT_RADIUS];
    }
}

- (void)mapDataUpdated:(NSNotification *)notification
{
    self.mapData = [NSMutableArray arrayWithArray:self.MessageStore.mapData];
    [self.map removeOverlays:self.messageOverlays];
    self.messageOverlays = [NSMutableArray arrayWithCapacity:MAP_DATA_ITEMS_LIMIT];
    for (NSDictionary *message in self.mapData) {
        [self.messageOverlays addObject:[self messageToOverlay:message]];
    }
    [self.map addOverlays:self.messageOverlays];
}

- (void)setFeedLocation:(CLLocationCoordinate2D)location andRadius:(CLLocationDistance)radiusMeters
{
    if (self.feedCircle) {
        [self.map removeOverlay:self.feedCircle];
    }
    self.feedCircle = [TAJMapCircle mapCircleWithCircle:[MKCircle circleWithCenterCoordinate:location radius:radiusMeters]];
    self.feedCircle.type = kTAJMapCircleTypeFeedLocation;
    [self.map addOverlay:self.feedCircle];
    CLLocation *clLocation = [[CLLocation alloc] initWithCoordinate:location altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:[NSDate date]];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:clLocation, @"location", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FeedLocationUpdated" object:self userInfo:userInfo];
}

- (TAJMapCircle *)messageToOverlay:(NSDictionary *)message
{
    double lat = [message[@"latitude"] doubleValue];
    double lng = [message[@"longitude"] doubleValue];
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lng);
    CLLocationDistance radius = MAP_DATA_ITEM_RADIUS;
    TAJMapCircle *circle = [TAJMapCircle mapCircleWithCircle:[MKCircle circleWithCenterCoordinate:location radius:radius]];
    circle.type = kTAJMapCircleTypeMessage;
    circle.opacity = 0.5;
    return circle;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    double maxLat = mapView.region.center.latitude + mapView.region.span.latitudeDelta;
    double minLat = mapView.region.center.latitude - mapView.region.span.latitudeDelta;
    double maxLng = mapView.region.center.longitude + mapView.region.span.longitudeDelta;
    double minLng = mapView.region.center.longitude - mapView.region.span.longitudeDelta;
    [self.MessageStore updateMapDataWithMaxLat:maxLat minLat:minLat maxLng:maxLng minLng:minLng limit:MAP_DATA_ITEMS_LIMIT];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (self.feedCircle == nil) {
        // If feed location is not yet set, zoom onto use location
        MKCoordinateRegion region = MKCoordinateRegionMake(self.map.userLocation.coordinate, MKCoordinateSpanMake(DEFAULT_ZOOM_SPAN, DEFAULT_ZOOM_SPAN));
        [self.map setRegion:region animated:YES];
        // And set feed location to user location
        [self setFeedLocation:self.map.userLocation.coordinate andRadius:DEFAULT_RADIUS];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[TAJMapCircle class]]) {
        TAJMapCircle *mapCircle = (TAJMapCircle *)overlay;
        if (mapCircle.type == kTAJMapCircleTypeFeedLocation) {
            // This is feed circle
            MKCircleRenderer *renderer = [[MKCircleRenderer alloc]initWithCircle:mapCircle.circle];
            renderer.fillColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
            renderer.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.7];
            renderer.lineWidth = 3;
            return renderer;
        } else {
            // This is message circle
            MKCircleRenderer *renderer = [[MKCircleRenderer alloc]initWithCircle:mapCircle.circle];
            renderer.fillColor = [[UIColor redColor] colorWithAlphaComponent:mapCircle.opacity];
            renderer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:mapCircle.opacity];
            renderer.lineWidth = 3;
            return renderer;
        }
    }
    // Some other type of overlay requested
    // We don't handle that, so return nil to cancel
    return nil;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"mapFeedNavSegue"]) {
        UINavigationController *navController = (UINavigationController *) [segue destinationViewController];
        TAJFeedViewController *feedViewController = [[navController viewControllers] objectAtIndex:0];
        feedViewController.MessageStore = self.MessageStore;
        feedViewController.LocationManager = self.LocationManager;
    }
}

@end

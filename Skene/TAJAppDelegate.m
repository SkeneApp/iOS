//
//  TAJAppDelegate.m
//  Skene
//
//  Created by Timo Jääskeläinen on 13.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import "TAJAppDelegate.h"
#import "TAJFeedViewController.h"
#import "TAJMessageStore.h"
#import "TAJLocationManager.h"
#import "TAJMapViewController.h"

@interface TAJAppDelegate ()

@property (nonatomic, strong) TAJMessageStore *messageStore;

@end

@implementation TAJAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initialize message store and location manager. These instances are going to be used all over the application
    TAJMessageStore *messageStore = [TAJMessageStore store];
    TAJLocationManager *locationManager = [[TAJLocationManager alloc] init];
    
    // Grab instances of view controllers that need configuration
    UINavigationController *tabViewController = (UINavigationController*) self.window.rootViewController;
    UINavigationController *feedNavController = [[tabViewController viewControllers] objectAtIndex:0];
    TAJFeedViewController *feedViewController = [[feedNavController viewControllers] objectAtIndex:0];
    TAJMapViewController *mapViewController = [[tabViewController viewControllers] objectAtIndex:1];
    
    // Give message store and location manager to feed and mav view controllers.
    feedViewController.MessageStore = messageStore;
    feedViewController.LocationManager = locationManager;
    
    mapViewController.MessageStore = messageStore;
    mapViewController.LocationManager = locationManager;
    
    return YES;
}

@end

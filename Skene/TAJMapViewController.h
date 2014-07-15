//
//  TAJMapViewController.h
//  Skene
//
//  Created by Timo Jääskeläinen on 13.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAJMessageStore.h"

@class TAJLocationManager;

@interface TAJMapViewController : UIViewController

// MessageStore and LocationManager are required for this controller to function and must be passed by someone from outside
@property (nonatomic, strong) TAJMessageStore *MessageStore;
@property (nonatomic, strong) TAJLocationManager *LocationManager;

@end

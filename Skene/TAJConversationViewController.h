//
//  TAJConversationViewController.h
//  Skene
//
//  Created by Timo Jääskeläinen on 13.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TAJMessageStore;
@class TAJLocationManager;

@interface TAJConversationViewController : UIViewController

// The parent message for this conversation. If nil, then user can post the first parent message (start a new conversation)
@property (nonatomic, strong) NSDictionary *parentMessage;

// MessageStore and LocationManager are required for this controller to function and must be passed by someone from outside
@property (nonatomic, strong) TAJMessageStore *MessageStore;
@property (nonatomic, strong) TAJLocationManager *LocationManager;

@end

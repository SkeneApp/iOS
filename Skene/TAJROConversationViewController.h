//
//  TAJROConversationViewController.h
//  Skene
//
//  Created by Timo Jääskeläinen on 13.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TAJMessageStore;

@interface TAJROConversationViewController : UITableViewController


@property (nonatomic, strong) NSDictionary *parentMessage;
@property (nonatomic, strong) TAJMessageStore *MessageStore;

@end

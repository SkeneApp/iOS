//
//  TAJFeedCell.h
//  Skene
//
//  Created by Timo Jääskeläinen on 13.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import <UIKit/UIKit.h>

// This cell is used to display a cell in a feed table.
// This cell leaves space on the right side for an arrow.

@interface TAJFeedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageTimeLabel;

@end

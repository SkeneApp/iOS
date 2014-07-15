//
//  TAJMessageCell.h
//  Skene
//
//  Created by Timo Jääskeläinen on 13.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import <UIKit/UIKit.h>

// This cell is used to display a cell in a conversation table.
// This cell uses the entire width of table and leaves no space for additional controls.

@interface TAJMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageTimeLabel;

@end

//
//  TAJROConversationViewController.m
//  Skene
//
//  Created by Timo Jääskeläinen on 13.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import "TAJROConversationViewController.h"
#import "TAJMessageCell.h"
#import "TAJMessageStore.h"
#import "NSDate+RelativeDate.h"
#import "TAJMessage.h"

@interface TAJROConversationViewController ()

@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic) int parentMessageId;
@property (nonatomic, strong) TAJMessageCell *helperCell;

@end

@implementation TAJROConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.parentMessage == nil) {
        // Parent message should not be nil, but if it is, don't let this crash
        TAJMessage *newMsg = [[TAJMessage alloc] init];
        newMsg.text = @"";
        newMsg.pubTime = [NSDate date];
        self.parentMessage = [newMsg toDictionary];
    }
    self.messages = [NSMutableArray arrayWithObject:self.parentMessage];
    NSString *parentMessageIdString = self.parentMessage[@"id"];
    self.parentMessageId = [parentMessageIdString intValue];
    if (self.MessageStore == nil) {
        NSLog(@"ROConversation: MessageStore is not set!!");
    }
    [self.MessageStore updateMessagesWithParentId:self.parentMessageId limit:50];
    
    // Instantiate helperCell from TAJMessageCell nib. This is only for cell height calculations.
    UINib *nib = [UINib nibWithNibName:@"TAJMessageCell" bundle:nil];
    // InstatiateWithOwner:options: returns an array of top level nib objects
    NSArray *nibObjects = [nib instantiateWithOwner:nil options:nil];
    // In thie case of TAJMessageCell there's one top level object, which is the TAJMessageCell object
    self.helperCell = nibObjects[0];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedMessagesUpdated:) name:TAJMessageStoreMessagesUpdated object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fixes tableview insets
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableView.scrollIndicatorInsets.top, self.tableView.scrollIndicatorInsets.left, 0, self.tableView.scrollIndicatorInsets.right);
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, 0, self.tableView.contentInset.right);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:(BOOL)animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAJMessageStoreMessagesUpdated object:nil];
}

- (void)feedMessagesUpdated:(NSNotification *)notification
{
    self.messages = [NSMutableArray arrayWithObject:self.parentMessage];
    NSArray* repliesInReverseOrder = [[self.MessageStore.messages reverseObjectEnumerator] allObjects];
    [self.messages addObjectsFromArray:repliesInReverseOrder];
    [self.tableView reloadData];
    [self scrollToBottom:self.tableView];
}

- (void)scrollToBottom:(UITableView *)tableView
{
    int numRows = [tableView numberOfRowsInSection:0];
    if (numRows > 0) {
        int lastRowNumber = [tableView numberOfRowsInSection:0]-1;
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TAJMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TAJMessageCell" forIndexPath:indexPath];
    
    [self configureCell:cell usingMessage:self.messages[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Add cell's content to helper cell
    [self configureCell:self.helperCell usingMessage:self.messages[indexPath.row]];
    
    // Tell it to update constrains, that will calculate the height, etc
    [self.helperCell layoutSubviews];
    
    // Get the required size for cell with this content
    CGSize reqSize = [self.helperCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return reqSize.height + 10;
}

- (void)configureCell:(TAJMessageCell *)cell usingMessage:(NSDictionary *)message
{
    cell.messageTextLabel.text = message[@"text"];
    NSString *unixTimeString = message[@"pubTime"];
    NSInteger unixTime = [unixTimeString integerValue];
    NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:unixTime];
    NSString *relativeTime = [dateTime relativeDateString];
    cell.messageTimeLabel.text = relativeTime;
}

@end

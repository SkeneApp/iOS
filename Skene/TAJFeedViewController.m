//
//  TAJFeedViewController.m
//  Skene
//
//  Created by Timo Jääskeläinen on 13.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import "TAJFeedViewController.h"
#import "TAJConversationViewController.h"
#import "TAJROConversationViewController.h"
#import "TAJFeedCell.h"
#import "TAJMessageStore.h"
#import "NSDate+RelativeDate.h"

// The default radius from where to get the conversations
#define DEFAULT_RADIUS 250
// The maximum number of conversations to fetch at once
#define CONVERSATION_LIMIT 50

@interface TAJFeedViewController ()

// Array holding a list of conversations. This is the data source for table view
@property (nonatomic, strong) NSArray *conversations;
// A helper cell instance is used for calculating size needed for table view
@property (nonatomic, strong) TAJFeedCell *helperCell;
// A pointer to the refresh control is stored, for when we need tell it to endRefreshing
@property (nonatomic, strong) id refreshTableSender;

@end

@implementation TAJFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.conversations = [[NSArray alloc] init];
    
    // Initialize helper cell, which will be needed for calculating cell sizes
    [self initHelperCell];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Subscribe for notifications
    BOOL isMapView = (self.LocationManager == nil);
    [self subscribeToNotifications:isMapView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fixes tableview insets - for some reason they are too far from the bottom after view appears
    [self fixTableInsets];
    
    if (self.LocationManager != nil) {
        if (self.LocationManager.currentLocation != nil) {
            // Message store might already have conversations loaded, get them
            self.conversations = self.MessageStore.conversations;
            // Ask to fetch the latest conversations
            [self updateConversations];
        }
    } else {
        [self updateConversations];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Always unsubscribe from notifications when view is going away
    BOOL isMapView = (self.LocationManager == nil);
    [self unsubscribeFromNotifications:isMapView];
}

- (void)updateConversations
{
    // latitude and longitude come from either user location or feed location on map
    double lat = self.LocationManager.currentLocation.coordinate.latitude;
    double lng = self.LocationManager.currentLocation.coordinate.longitude;
    // If lat and lng were never set, don't bother
    if (lat != 0 || lng != 0) {
        [self.MessageStore updateConversationsAtLatitude:lat longitude:lng withinRadius:DEFAULT_RADIUS limit:CONVERSATION_LIMIT];
    }
}

#pragma mark - Table view related methods

- (void)initHelperCell
{
    // Instantiate helperCell from TAJFeedCell nib.
    // This is only for cell height calculations.
    UINib *nib = [UINib nibWithNibName:@"TAJFeedCell" bundle:nil];
    // InstatiateWithOwner:options: returns an array of top level nib objects
    NSArray *nibObjects = [nib instantiateWithOwner:nil options:nil];
    // In thie case of TAJFeedCell there's one top level object, which is the TAJFeedCell object
    self.helperCell = nibObjects[0];
}

- (void)fixTableInsets
{
    // Fixes tableview insets - for some reason they are too far from the bottom after view appears
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableView.scrollIndicatorInsets.top, self.tableView.scrollIndicatorInsets.left, 0, self.tableView.scrollIndicatorInsets.right);
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, 0, self.tableView.contentInset.right);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.conversations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TAJFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TAJFeedCell" forIndexPath:indexPath];
    [self configureCell:cell usingMessage:self.conversations[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Use helper cell to calculate the height needed to fit the content of this row.
    
    // Add the conent to the helper cell
    [self configureCell:self.helperCell usingMessage:self.conversations[indexPath.row]];
    // Tell it to update constrains, that will calculate the size of the entire cell
    [self.helperCell layoutSubviews];
    // Get the required size for cell with this content and return its height
    CGSize reqSize = [self.helperCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    // TODO: something is off in IB, cells are messed up unless required height is increased by a small amount
    return reqSize.height + 10;
}

- (void)configureCell:(TAJFeedCell *)cell usingMessage:(NSDictionary *)message
{
    cell.messageTextLabel.text = message[@"text"];
    // Convert unix timestamp of the message to relative time string
    NSInteger unixTime = [message[@"pubTime"] integerValue];
    NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:unixTime];
    NSString *relativeTime = [dateTime relativeDateString];
    cell.messageTimeLabel.text = relativeTime;
}

#pragma mark - Notifications

- (void)subscribeToNotifications:(BOOL)isMapView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedMessagesUpdated:) name:TAJMessageStoreConversationsUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLocationUpdated:) name:self.LocationManager.updateNotificationName object:nil];
}

- (void)unsubscribeFromNotifications:(BOOL)isMapView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAJMessageStoreConversationsUpdated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:self.LocationManager.updateNotificationName object:nil];
}

- (void)feedMessagesUpdated:(NSNotification *)notification
{
    self.conversations = self.MessageStore.conversations;
    [self.tableView reloadData];
    [self.refreshTableSender endRefreshing];
}

- (void)userLocationUpdated:(NSNotification *)notification
{
    [self updateConversations];
}

#pragma mark - Segue transition handler

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // This segue is used in the feed page, when a conversation is clicked.
    // It opens the conersation view that allows user to reply.
    if ([[segue identifier] isEqualToString:@"OpenConversationSegue"])
    {
        TAJConversationViewController *cvc = [segue destinationViewController];
        NSInteger selectedRow = [self.tableView indexPathForSelectedRow].row;
        NSDictionary *parentMessage = self.conversations[selectedRow];
        cvc.parentMessage = parentMessage;
        cvc.LocationManager = self.LocationManager;
        cvc.MessageStore = self.MessageStore;
    }
    
    
    // This segue is used in the feed page, when a new conversation button is clicked.
    // It opens an empty conversation and user can post the first message.
    if ([[segue identifier] isEqualToString:@"NewConversationSegue"])
    {
        TAJConversationViewController *cvc = [segue destinationViewController];
        cvc.LocationManager = self.LocationManager;
        cvc.MessageStore = self.MessageStore;
        cvc.parentMessage = nil;
    }
    
    // This segues is used in the map page, when a conversation is clicked.
    // It opens the conversation view in read only mode.
    if ([[segue identifier] isEqualToString:@"ROOpenConversationSegue"])
    {
        TAJROConversationViewController *cvc = [segue destinationViewController];
        NSInteger selectedRow = [self.tableView indexPathForSelectedRow].row;
        NSDictionary *parentMessage = self.conversations[selectedRow];
        cvc.parentMessage = parentMessage;
        cvc.MessageStore = self.MessageStore;
    }
    
    
}

#pragma mark - UI Action handlers

- (IBAction)refreshTable:(id)sender
{
    // User dragged the table view down, triggering a refresh action
    [self updateConversations];
    self.refreshTableSender = sender;
}
@end

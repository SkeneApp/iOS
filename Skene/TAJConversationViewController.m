//
//  TAJConversationViewController.m
//  Skene
//
//  Created by Timo Jääskeläinen on 13.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import "TAJConversationViewController.h"
#import "TAJMessageStore.h"
#import "TAJLocationManager.h"
#import "TAJMessageCell.h"
#import "NSDate+RelativeDate.h"

#define MESSAGE_MAX_LEN 140

@interface TAJConversationViewController () <UITableViewDataSource, UITextFieldDelegate, UITableViewDelegate>

// Outlets from Interface Builder
// Message input is needed to get the text of a new message
@property (weak, nonatomic) IBOutlet UITextField *messageInput;
// Send button reference to disable/enable send button
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
// Constraints are needed to be modified when keyboard is appearing/disappearing
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendButtonBottomConstraint;
// Since this view controller is not a UITableViewController, we need a reference to the table
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Keyboard height is saved when keyboard appears and the value is used for animation when keyboard disappears
@property (nonatomic) float keyboardHeight;
// This is a list of messages that are displated in the table view
@property (nonatomic, strong) NSMutableArray *messages;
// Parent message ID is saved for fast access. TODO: Start using TAJMessage and get rid of this
@property (nonatomic) int parentMessageId;
// A helper cell instance is used for calculating size needed for table view
@property (nonatomic, strong) TAJMessageCell *helperCell;

@end

@implementation TAJConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeMessages];
    
    // Initialize helper cell, which will be needed for calculating cell sizes
    [self initHelperCell];
}

- (void)initializeMessages
{
    if (self.parentMessage == nil) {
        self.messages = [[NSMutableArray alloc] init];
    } else {
        self.messages = [NSMutableArray arrayWithObject:self.parentMessage];
        NSString *parentMessageIdString = self.parentMessage[@"id"];
        self.parentMessageId = [parentMessageIdString intValue];
        [self.MessageStore updateMessagesWithParentId:self.parentMessageId limit:50];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:(BOOL)animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedMessagesUpdated:) name:TAJMessageStoreMessagesUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageIdReceived:) name:TAJMessageStoreNewIdReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLocationUpdated:) name:TAJUserLocationUpdated object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:(BOOL)animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAJMessageStoreMessagesUpdated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAJMessageStoreNewIdReceived object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAJUserLocationUpdated object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // If this is a new conversation, set focus on the input text
    if (self.parentMessage == nil) {
        [self.messageInput becomeFirstResponder];
    }
}

- (void)feedMessagesUpdated:(NSNotification *)notification
{
    self.messages = [NSMutableArray arrayWithObject:self.parentMessage];
    NSArray* repliesInReverseOrder = [[self.MessageStore.messages reverseObjectEnumerator] allObjects];
    [self.messages addObjectsFromArray:repliesInReverseOrder];
    [self.tableView reloadData];
    [self scrollToBottom:self.tableView];
}

- (void)newMessageIdReceived:(NSNotification *)notification
{
    if ([self.parentMessage[@"id"] isEqualToString:@"-1"]) {
        self.parentMessage = [self setId:self.MessageStore.lastMessageId forMessage:self.parentMessage];
        self.parentMessageId = self.MessageStore.lastMessageId;
        self.messages[0] = [self setId:self.MessageStore.lastMessageId forMessage:self.parentMessage];
    } else {
        NSDictionary *lastMessage = self.messages[[self.messages count] - 1];
        self.messages[[self.messages count] - 1] = [self setId:self.MessageStore.lastMessageId forMessage:lastMessage];
    }
    NSLog(@"Set message IDs:\n%@", self.messages);
}

- (NSDictionary *)setId:(int)newId forMessage:(NSDictionary *)message
{
    NSMutableDictionary *newMessage = [NSMutableDictionary dictionaryWithDictionary:@{
                                 @"id": [NSString stringWithFormat:@"%d", newId]
                                 }];
    if (message[@"text"] != nil) {
        newMessage[@"text"] = message[@"text"];
    }
    if (message[@"latitude"] != nil) {
        newMessage[@"latitude"] = message[@"latitude"];
    }
    if (message[@"longitude"] != nil) {
        newMessage[@"longitude"] = message[@"longitude"];
    }
    if (message[@"pubTime"] != nil) {
        newMessage[@"pubTime"] = message[@"pubTime"];
    }
    if (message[@"parent_id"] != nil) {
        newMessage[@"parent_id"] = message[@"parent_id"];
    }
    
    return newMessage;
}

- (void)userLocationUpdated:(NSNotification *)notification
{
    // TODO: See if distance from parent message is too far, then disable replying
}

#pragma mark - Notification handlers

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardHeight = keyboardFrame.size.height;
    
    self.textFieldBottomConstraint.constant += self.keyboardHeight;
    self.sendButtonBottomConstraint.constant += self.keyboardHeight;
    
    // Animate the layout change along with keyboard animation
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    
    // Enable the send button if there's some text in the text box
    if ([self.messageInput.text length] > 0) {
        self.sendButton.enabled = YES;
    }
    
    // Scroll to the bottom of the table
    [self scrollToBottom:self.tableView];
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    // Disable send button while text field is not active
    self.sendButton.enabled = NO;
    
    // Adjust bottom constraints using animation while the keyboard is sliding away
    self.textFieldBottomConstraint.constant -= self.keyboardHeight;
    self.sendButtonBottomConstraint.constant -= self.keyboardHeight;
    
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    
    [self.view layoutIfNeeded];
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

#pragma mark - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    // Enable or disable keyboard depending on whether there's any text in the text field
    if (newLength > 0) {
        self.sendButton.enabled = YES;
    } else {
        self.sendButton.enabled = NO;
    }
    return (newLength > MESSAGE_MAX_LEN) ? NO : YES;
}


#pragma mark - Table view related methods

- (void)initHelperCell
{
    // Instantiate helperCell from TAJMessageCell nib. This is only for cell height calculations.
    UINib *nib = [UINib nibWithNibName:@"TAJMessageCell" bundle:nil];
    // InstatiateWithOwner:options: returns an array of top level nib objects
    NSArray *nibObjects = [nib instantiateWithOwner:nil options:nil];
    // In thie case of TAJMessageCell there's one top level object, which is the TAJMessageCell object
    self.helperCell = nibObjects[0];
}

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

- (IBAction)sendPressed:(id)sender
{
    NSString *text = self.messageInput.text;
    int delaySec = 0;
    double lat = 0;
    double lng = 0;
    if (self.parentMessage == nil) {
        lat = self.LocationManager.currentLocation.coordinate.latitude;
        lng = self.LocationManager.currentLocation.coordinate.longitude;
        [self.MessageStore postMessageAtLatitude:lat longitude:lng withText:text delay:delaySec parent:0];
    } else {
        lat = [self.parentMessage[@"latitude"] doubleValue];
        lng = [self.parentMessage[@"longitude"] doubleValue];
        [self.MessageStore postMessageAtLatitude:lat longitude:lng withText:text delay:delaySec parent:self.parentMessageId];
    }
    // Add new message to the conversation
    NSString *unixTimeStampNow = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
    NSDictionary *message = @{
                              @"text": text,
                              @"pubTime": unixTimeStampNow,
                              @"id": @"-1",
                              @"latitude": [NSString stringWithFormat:@"%f", lat],
                              @"longitude": [NSString stringWithFormat:@"%f", lng]
                              };
    [self.messages addObject:message];
    if (self.parentMessage == nil) {
        self.parentMessage = message;
        // TODO: Set parent ID
    }
    [self.tableView reloadData];
    
    // Clear the input field and dismiss the keyboard
    self.messageInput.text = @"";
    [self.messageInput resignFirstResponder];
    
}

@end

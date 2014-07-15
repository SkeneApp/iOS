//
//  TAJMessageStore.h
//  Skene
//
//  Created by Timo Jääskeläinen on 13.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import <Foundation/Foundation.h>

// Name constants for various notifications that MessageStore emits
// Emitted after a list of messages form a given parent was updated
extern NSString * const TAJMessageStoreMessagesUpdated;
// Emitted after a list of conversations from a given location was updated
extern NSString * const TAJMessageStoreConversationsUpdated;
// Emitted after map data was updated
extern NSString * const TAJMessageStoreMapDataUpdated;
// Emitted after a new message was posted and server responded with new message ID
extern NSString * const TAJMessageStoreNewIdReceived;

@interface TAJMessageStore : NSObject

// Initializes and returns a new instance of a MessageStore
+ (instancetype)store;

// Arrays containing last data received
@property (readonly, nonatomic, strong) NSArray *conversations;
@property (readonly, nonatomic, strong) NSArray *messages;
@property (readonly, nonatomic, strong) NSArray *mapData;

// Last refresh time (for any data type)
@property (readonly, nonatomic, strong) NSDate *lastRefresh;
// The ID of the last posted message (returned by server after message is saved to database successfully)
@property (readonly, nonatomic) int lastMessageId;

// Get a list of conversations from a given location
- (void)updateConversationsAtLatitude:(double)lat longitude:(double)lng withinRadius:(int)radiusMeters limit:(int)maxMessages;
// Get a list of messages from a given coversation (parent_id defines conversation)
- (void)updateMessagesWithParentId:(int)parent_id limit:(int)maxMessages;
// Get map data for a given area
- (void)updateMapDataWithMaxLat:(double)maxLat minLat:(double)minLat maxLng:(double)maxLng minLng:(double)minLng limit:(int)maxMessages;
// Post a new message
- (void)postMessageAtLatitude:(double)lat longitude:(double)lng withText:(NSString *)text delay:(int)delaySec parent:(int)parentId;

@end

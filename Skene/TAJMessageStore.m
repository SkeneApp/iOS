//
//  TAJMessageStore.m
//  Skene
//
//  Created by Timo Jääskeläinen on 13.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import "TAJMessageStore.h"

// Name constants for various notifications that MessageStore emits
NSString *const TAJMessageStoreMessagesUpdated = @"TAJMessageStoreMessagesUpdated";
NSString *const TAJMessageStoreConversationsUpdated = @"TAJMessageStoreConversationsUpdated";
NSString *const TAJMessageStoreMapDataUpdated = @"TAJMessageStoreMapDataUpdated";
NSString *const TAJMessageStoreNewIdReceived = @"TAJMessageNewMessageIdReceived";

@interface TAJMessageStore ()

@property (nonatomic) NSURLSession *session;

@end

@implementation TAJMessageStore

+ (instancetype)store
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initSession];
    }
    return self;
}

- (void)initSession
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
}

- (void)updateConversationsAtLatitude:(double)lat longitude:(double)lng withinRadius:(int)radiusMeters limit:(int)maxMessages
{
    NSString *requestString = [NSString stringWithFormat:@"http://whispr.outi.me/api/v2_get?lat=%f&long=%f&radius=%d&count=%d", lat, lng, radiusMeters, maxMessages];
    NSURLRequest *request = [self requestFromUrlString:requestString];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        _conversations = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        _lastRefresh = [NSDate date];
        [self notify:TAJMessageStoreConversationsUpdated];
    }];
    [task resume];
}

- (void)updateMapDataWithMaxLat:(double)maxLat minLat:(double)minLat maxLng:(double)maxLng minLng:(double)minLng limit:(int)maxMessages
{
    NSString *requestString = [NSString stringWithFormat:@"http://whispr.outi.me/api/v2_get_map_data?max_lat=%f&min_lat=%f&max_long=%f&min_long=%f&count=%d", maxLat, minLat, maxLng, minLng, maxMessages];
    NSURLRequest *request = [self requestFromUrlString:requestString];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        _mapData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        _lastRefresh = [NSDate date];
        [self notify:TAJMessageStoreMapDataUpdated];
    }];
    [task resume];
}

- (void)updateMessagesWithParentId:(int)parent_id limit:(int)maxMessages
{
    NSString *requestString = [NSString stringWithFormat:@"http://whispr.outi.me/api/v2_get?count=%d&parent_id=%d", maxMessages, parent_id];
    NSURLRequest *request = [self requestFromUrlString:requestString];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        _messages = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        _lastRefresh = [NSDate date];
        [self notify:TAJMessageStoreMessagesUpdated];
    }];
    [task resume];
}

- (void)postMessageAtLatitude:(double)lat longitude:(double)lng withText:(NSString *)text delay:(int)delaySec parent:(int)parentId
{
    // Use dictionary that will be serialized into JSON
    NSDictionary *message = @{
                              @"latitude": [NSString stringWithFormat:@"%f", lat],
                              @"longitude": [NSString stringWithFormat:@"%f", lng],
                              @"text": text,
                              @"pubDelay": [NSString stringWithFormat:@"%d", delaySec],
                              @"parent_id": [NSString stringWithFormat:@"%d", parentId]
                              };
    
    // Compose POST request with JSON data
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
    NSURL *url = [NSURL URLWithString:@"http://whispr.outi.me/api/v2_add"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = JSONData;
    
    // Initialize URL session and provide callback
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            // The server returns an ID of the last message posted. Get it and save to lastMessageId property
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _lastMessageId = [dataString intValue];
            [self notify:TAJMessageStoreNewIdReceived];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    
    // Start the session task (sends request)
    [task resume];
}

- (void)notify:(NSString *)notificationName
{
    // Update UI on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
    });
}

- (NSURLRequest *)requestFromUrlString:(NSString *)string
{
    NSURL *url = [NSURL URLWithString:string];
    return [NSURLRequest requestWithURL:url];
}

@end

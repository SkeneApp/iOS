//
//  TAJMessage.m
//  Skene
//
//  Created by Timo Jääskeläinen on 14.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import "TAJMessage.h"

@implementation TAJMessage

- (instancetype)messageFromDictionary:(NSDictionary *)dict
{
    TAJMessage *message = [[TAJMessage alloc] init];
    
    if (dict[@"id"] != nil) {
        message.messageId = [dict[@"id"] intValue];
    }
    if (dict[@"text"] != nil) {
        message.text = dict[@"text"];
    }
    if (dict[@"latitude"] != nil) {
        message.latitude = [dict[@"latitude"] doubleValue];
    }
    if (dict[@"longitude"] != nil) {
        message.longitude = [dict[@"longitude"] doubleValue];
    }
    if (dict[@"pubTime"] != nil) {
        long unixTimeStamp = [dict[@"pubTime"] longValue];
        message.pubTime = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
    }
    if (dict[@"parent_id"] != nil) {
        message.parentId = [dict[@"parent_id"] intValue];
    }
    
    return message;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:6];
    dict[@"id"] = [NSString stringWithFormat:@"%d", self.messageId];
    if (self.text != nil) {
        dict[@"text"] = self.text;
    }
    dict[@"latitude"] = [NSString stringWithFormat:@"%f", self.latitude];
    dict[@"longitude"] = [NSString stringWithFormat:@"%f", self.longitude];
    if (self.pubTime != nil) {
        dict[@"pubTime"] = self.pubTime;
    }
    dict[@"parent_id"] = [NSString stringWithFormat:@"%d", self.parentId];
    return dict;
}

@end

//
//  TAJMessage.h
//  Skene
//
//  Created by Timo Jääskeläinen on 14.7.2014.
//  Copyright (c) 2014 Timo Jääskeläinen. All rights reserved.
//

#import <Foundation/Foundation.h>

// A class representing a Skene message object.
// Work in progress.

@interface TAJMessage : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, copy) NSDate *pubTime;
@property (nonatomic) int messageId;
@property (nonatomic) int parentId;
@property (nonatomic) int delaySec;

- (instancetype)messageFromDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;

@end

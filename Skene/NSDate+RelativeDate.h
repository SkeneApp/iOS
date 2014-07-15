//
//  NSDate+RelativeDate.h
//  Skene
//
//

#import <Foundation/Foundation.h>

@interface NSDate (RelativeDate)

// Returns a relative date/time string (eg. "3 seconds ago")
- (NSString *)relativeDateString;

@end

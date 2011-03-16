
// Meet.m
// kaya meet 
//
#import <sys/time.h>
#import "Meet.h"
#import "REString.h"
#import "kaya_meetAppDelegate.h"

@implementation Meet

@synthesize meetId, postId;
@synthesize description;

@synthesize updateAt, timeAt, userCount, meetUsers;
@synthesize timestamp;
@synthesize longitude, latitude;
@synthesize type;


- (void)dealloc
{
    [description release];
    [timestamp release];
  	[super dealloc];
}

//static NSString *userRegexp = @"@([0-9a-zA-Z_]+)";

- (NSString*)timestamp
{
    // Calculate distance time string
    //
    time_t now;
    time(&now);

    int distance = (int)difftime(now, timeAt);
    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "second ago" : "seconds ago"];
    }
    else if (distance < 60 * 60) {  
        distance = distance / 60;
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "minute ago" : "minutes ago"];
    }  
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "hour ago" : "hours ago"];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "day ago" : "days ago"];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "week ago" : "weeks ago"];
    }
    else {
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeAt];        
        self.timestamp = [dateFormatter stringFromDate:date];
    }
    return timestamp;
}

@end

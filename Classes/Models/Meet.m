
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

@synthesize textBounds;
@synthesize bubbleRect;
@synthesize cellHeight;

@synthesize accessoryType;

- (void)dealloc
{
    [description release];
    [timestamp release];
  	[super dealloc];
}

- (void)calcTextBounds:(int)textWidth
{
    CGRect bounds, result;
    
    if (type == KYMEET_TYPE_SENT) {
        bounds = CGRectMake(0, TOP, textWidth, 200);
    }
    else { // KYMEET_TYPE_UPDATE, KYMEET_TYPE_TEMP
        bounds = CGRectMake(0, 3, textWidth, 200);
    }
    
    static UILabel *label = nil;
    if (label == nil) {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    label.font = [UIFont systemFontOfSize:(type == KYMEET_TYPE_UPDATE) ? 14 : 13];
    label.text = description;
    result = [label textRectForBounds:bounds limitedToNumberOfLines:20];
    
    textBounds = CGRectMake(bounds.origin.x, bounds.origin.y, textWidth, result.size.height);
    
    if (type == KYMEET_TYPE_SENT) {
        result.size.height += 18 + 15 + 2;
        if (result.size.height < IMAGE_WIDTH + 1) result.size.height = IMAGE_WIDTH + 1;
    }
    else {
        result.size.height += 22;
    }
    cellHeight = result.size.height;
}

static NSString *userRegexp = @"@([0-9a-zA-Z_]+)";
//static NSString *hashRegexp = @"(#[a-zA-Z0-9\\-_\\.+:=]+)";

- (void)updateAttribute
{
    NSRange range;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *tmp = description;
    int hasUsername = 0;
	// count number of people met
    while ([tmp matches:userRegexp withSubstring:array]) {
        NSString *match = [array objectAtIndex:0]; 
		++hasUsername;
        range = [tmp rangeOfString:match];
        tmp = [tmp substringFromIndex:range.location + range.length];
        [array removeAllObjects];
    }
	[array release];
   
	// findout if there is any html link
    range = [description rangeOfString:@"http://"];
    if (range.location != NSNotFound || hasUsername) {    
        accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    else {
		accessoryType = UITableViewCellAccessoryNone;
	}
}

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

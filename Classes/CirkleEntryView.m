//
//  CirkleEntryView.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/27/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirkleEntryView.h"
#import "kaya_meetAppDelegate.h"

#define GENERIC_MARGIN			5
#define	PIC_WIDTH				47

#define NAME_TOP_X				(GENERIC_MARGIN+GENERIC_MARGIN+PIC_WIDTH)
#define	NAME_TOP_WIDTH			205

#define LOGO_TOP_X				(NAME_TOP_X+NAME_TOP_WIDTH+GENERIC_MARGIN)
#define LOGO_TOP_Y				(GENERIC_MARGIN+12)
#define LOGO_WIDTH				24

#define	TIME_TOP_X				(LOGO_TOP_X+LOGO_WIDTH+5)
#define TIME_TOP_Y				(GENERIC_MARGIN+17)
#define TIME_WIDTH				24

#define CONTENT_TOP_X			NAME_TOP_X
#define CONTENT_TOP_Y			(GENERIC_MARGIN + PIC_WIDTH + GENERIC_MARGIN)
#define CONTENT_WIDTH			244

#define MAIN_FONT_SIZE			12
#define MIN_MAIN_FONT_SIZE		10
#define SECONDARY_FONT_SIZE		10
#define MIN_SECONDARY_FONT_SIZE 10

@implementation CirkleEntryView
@synthesize nameString;
@synthesize pic;
@synthesize circleLogo;
@synthesize timeString;
@synthesize contentString;
@synthesize userImage;
@synthesize userId;
@synthesize circle;
@synthesize images;
@synthesize size;

- (void)setCircle:(CirkleSummary *)aCircle {
    
    circle = aCircle;
    
    // variable text
    UIFont *mainFont = [UIFont systemFontOfSize:12];
    
    CGRect drawRect = CGRectMake(57, 0, 244, 9999.0);
    NSString *varString = circle.contentString;
    
    size = [varString sizeWithFont:mainFont 
                     constrainedToSize:drawRect.size];
    
    //NSLog(@"cell variable Text Size = %@", NSStringFromCGSize(size));
    
    // check circle.score
    if (circle.score==1) {
        circleLogo = [UIImage imageNamed:@"circle_logo_1.png"];
    } else if (circle.score==2) {
        circleLogo = [UIImage imageNamed:@"circle_logo_2.png"];
    } else {
        circleLogo = [UIImage imageNamed:@"circle_logo_3.png"];
    }
    
    // calculate time string
    [self updateTimeString];
    
    //set the user image url
    kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
    User *user = circle.user;
    
    [userImage clear];
	userImage.url = [NSURL URLWithString:[user.profileImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	userImage.oid = [NSString stringWithFormat:@"user_%d",user.userId];
	[delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:userImage waitUntilDone:YES];
    
    NSEnumerator *enumerator = [circle.imageUrl objectEnumerator];
    NSEnumerator *image_enum = [images objectEnumerator];
    
    NSString *imgurl;
    CGRect contentRect = self.bounds;
    CGFloat boundsX = contentRect.origin.x;
    int i = 0;
    HJManagedImageV *img;
    
    //clear old images
    while ((img = [image_enum nextObject])) {
        [img clear];
    }
    
    // reset
    image_enum = [images objectEnumerator];
    
    while ((imgurl = [enumerator nextObject])) {
        
        drawRect = CGRectMake(boundsX+CONTENT_TOP_X+i*(54+5), CONTENT_TOP_Y + size.height + 5, PIC_WIDTH, PIC_WIDTH);
        img = [image_enum nextObject];
        img.frame = drawRect;
                
        //[img clear];
        img.url = [NSURL URLWithString:imgurl];
        [delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:img waitUntilDone:YES];
        //[delg.objMan manage:img];
        [self addSubview:img];

        //NSLog(@"%@", img.url);
        
        i++;
        if(i>=4)
            break;
    }
    
	[self setNeedsDisplay];

}

//when the time string change, we need to redisplay
//this is the onlt thing that changes over time in this cell

- (void)updateTimeString
{
    // Calculate distance time string
    //
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now, circle.timeAt);
    
    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        self.timeString = [NSString stringWithFormat:@"%ds", distance];
    }
    else if (distance < 60 * 60) {  
        distance = distance / 60;
        self.timeString = [NSString stringWithFormat:@"%dm",distance];
    }  
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        self.timeString = [NSString stringWithFormat:@"%dh",distance];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        self.timeString = [NSString stringWithFormat:@"%dd",distance];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        self.timeString = [NSString stringWithFormat:@"%dw",distance];
    }
    else {
        //to-do: i have not enough space to display it - readjust cell view
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:circle.timeAt];        
        self.timeString = [dateFormatter stringFromDate:date];
    }
    
    //NSLog(@"timestring is %@", timeString);
    return;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect contentRect = self.bounds;
        CGFloat boundsX = contentRect.origin.x;
        
        CGRect drawRect = CGRectMake(boundsX+GENERIC_MARGIN, GENERIC_MARGIN, PIC_WIDTH, PIC_WIDTH);
        
        userImage = [[HJManagedImageV alloc] initWithFrame:drawRect];
        
        [self addSubview:userImage];
        
        images = [[NSMutableArray alloc] init];
        [images addObject:[[HJManagedImageV alloc] init]];
        [images addObject:[[HJManagedImageV alloc] init]];
        [images addObject:[[HJManagedImageV alloc] init]];
        [images addObject:[[HJManagedImageV alloc] init]];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.


//this class overwrite the drawRect method to customize how it will look
- (void)drawRect:(CGRect)rect {
    
	//define my layout
	
	// Font for name
	UIFont *nameFont = [UIFont boldSystemFontOfSize:12];
	
	// Color and font for the main text items
	UIColor *mainTextColor = nil;
	UIFont *mainFont = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
	
	// Color and font for the secondary text items
	UIColor *secondaryTextColor = nil;
	UIFont *secondaryFont = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];
	
	mainTextColor = [UIColor blackColor];
	secondaryTextColor = [UIColor darkGrayColor];
	self.backgroundColor = [UIColor whiteColor];
	
	CGRect contentRect = self.bounds;
	
	[[UIColor whiteColor] set];
	UIRectFill(contentRect);
	
	//we will never edit
	if (1) {
		CGFloat boundsX = contentRect.origin.x;
		CGPoint point;
		
		// Set the color for the main text items.
		[mainTextColor set];
        
		// Draw the picture
		point = CGPointMake(boundsX+GENERIC_MARGIN, GENERIC_MARGIN);
		
		[pic drawAtPoint:point];
		
		// Draw name
		point = CGPointMake(boundsX + NAME_TOP_X, GENERIC_MARGIN);
		[circle.nameString drawAtPoint:point 
					   forWidth:NAME_TOP_WIDTH 
					   withFont:nameFont 
					minFontSize:MIN_MAIN_FONT_SIZE
				 actualFontSize:NULL 
				  lineBreakMode:UILineBreakModeTailTruncation 
			 baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		
		// Draw logo
		point = CGPointMake(boundsX + LOGO_TOP_X, LOGO_TOP_Y);
		[circleLogo drawAtPoint:point];
		
		// Draw timestring
		[secondaryTextColor set];
        
		point = CGPointMake(boundsX + TIME_TOP_X, TIME_TOP_Y);
		[timeString drawAtPoint:point 
                       forWidth:TIME_WIDTH 
                       withFont:secondaryFont 
                    minFontSize:MIN_SECONDARY_FONT_SIZE 
                 actualFontSize:NULL 
                  lineBreakMode:UILineBreakModeTailTruncation 
             baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		
		// Content
		// first icon
		UIImage *icon = [UIImage imageNamed:@"group_people_icon.png"];
		//point = CGPointMake(boundsX+19.5, CONTENT_TOP_Y+5);
		//[icon drawAtPoint:point];
        
		// Draw text content
		CGRect drawRect = CGRectMake(boundsX+CONTENT_TOP_X, CONTENT_TOP_Y, CONTENT_WIDTH, 9999.0);
		        
		drawRect.size = size;
        
		[circle.contentString drawInRect:drawRect withFont:mainFont];
		
		// Draw flashback icon
		icon = [UIImage imageNamed:@"flashback_icon.png"];
		point = CGPointMake(boundsX+19.5, CONTENT_TOP_Y + size.height + 5 + 5);
		[icon drawAtPoint:point];
		
		//that's it
	}
}


- (void)dealloc
{
    [nameString release];
	[pic release];
	[circleLogo release];
	[timeString release];
	[contentString release];
    [images removeAllObjects];
    [images release];
    
    [super dealloc];
}

@end

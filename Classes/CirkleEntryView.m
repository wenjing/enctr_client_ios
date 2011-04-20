//
//  CirkleEntryView.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/27/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirkleEntryView.h"
#import "kaya_meetAppDelegate.h"

@implementation CirkleEntryView


////@synthesize circleLogo;
//@synthesize timeString;

@synthesize userImage;

@synthesize circle;
@synthesize images;
@synthesize size;

// Don't allocate memory resource here
- (void)setCircle:(CirkleSummary *)aCircle {
    
    circle = aCircle;
    
    //set the user image url
    kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
    //User *user = circle.user; //not used anymore
    
    if (circle.avatarUrl!=nil) {
        [userImage clear];
        userImage.url = circle.avatarUrl;
        [delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:userImage waitUntilDone:YES];
        //[delg.objMan manage:userImage];
        //NSLog(@"user %d name %@ url %@ full url=%@", user.userId, user.name, user.profileImageUrl, userImage.url);
    }
    
    NSEnumerator *enumerator = [circle.imageUrl objectEnumerator];
    NSEnumerator *image_enum = [images objectEnumerator];
    
    NSURL *imgurl;
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
        
        CGRect drawRect = CGRectMake(boundsX+CONTENT_TOP_X+i*(LG_PIC_SIZE+GENERIC_MARGIN), 
                              CONTENT_TOP_Y + circle.size.height + 5, LG_PIC_SIZE, LG_PIC_SIZE);
        img = [image_enum nextObject];
        img.frame = drawRect;
                
        img.url = imgurl;
        [delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:img waitUntilDone:YES];
        //[delg.objMan manage:img];
        
        i++;
        if(i>=4)
            break;
    }
    
	[self setNeedsDisplay];

}


- (NSString *)updateTimeString
{
    // Calculate distance time string
    //
    NSString *timeString;
    
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now, circle.timeAt);
    
    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        timeString = [NSString stringWithFormat:@"%dsec", distance];
    }
    else if (distance < 60 * 60) {  
        distance = distance / 60;
        timeString = [NSString stringWithFormat:@"%dmin",distance];
    }  
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        timeString = [NSString stringWithFormat:@"%dhr",distance];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        timeString = [NSString stringWithFormat:@"%dday",distance];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        timeString = [NSString stringWithFormat:@"%dwk",distance];
    }
    else {
        //to-do: i have not enough space to display it - readjust cell view
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            
            NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"dMMM" options:0
                                                                      locale:[NSLocale currentLocale]];
            [dateFormatter setDateFormat:formatString];
        }
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:circle.timeAt];        
        timeString = [dateFormatter stringFromDate:date];
    }
    
    //NSLog(@"timestring is %@", timeString);
    return timeString;
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
        
        //step1: do addSubView here
        HJManagedImageV *imageView;
        
        images = [[NSMutableArray alloc] init];
        
        for (int i=0; i<4; i++) {
            
            imageView = [[HJManagedImageV alloc] init];
            [self addSubview:imageView];
            [images addObject:imageView];
        }
        
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
	UIColor *mainTextColor = [UIColor blackColor];
	UIFont *mainFont = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
	
	// Color and font for the secondary text items
	UIColor *secondaryTextColor = [UIColor darkGrayColor];
	UIFont *secondaryFont = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];
	
	self.backgroundColor = [UIColor whiteColor];
    
	CGRect contentRect = self.bounds;
	
	[[UIColor whiteColor] set];
	UIRectFill(contentRect);
	
    kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
    
	//we will never edit
	if (1) {
		CGFloat boundsX = contentRect.origin.x;
		CGPoint point;
		
		// Set the color for the main text items.
		[mainTextColor set];
        
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
        // check circle.score
        UIImage *logo;
        
        if (circle.type == CIRCLE_TYPE_INVITE) {
            logo = [delg.cachedImages objectAtIndex:9];
        } else
        if (circle.score==1) {
            logo = [delg.cachedImages objectAtIndex:0];
        } else if (circle.score==2) {
            logo = [delg.cachedImages objectAtIndex:1];
        } else {
            logo = [delg.cachedImages objectAtIndex:2];
        }

		point = CGPointMake(boundsX + LOGO_TOP_X, LOGO_TOP_Y);
		[logo drawAtPoint:point];
		
		// Draw timestring
		[secondaryTextColor set];
        NSString *timeString = [self updateTimeString];
        
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
		UIImage *icon;// = [UIImage imageNamed:@"group_people_icon.png"];
		//point = CGPointMake(boundsX+19.5, CONTENT_TOP_Y+5);
		//[icon drawAtPoint:point];
        
		// Draw text content
		CGRect drawRect = CGRectMake(boundsX+CONTENT_TOP_X, CONTENT_TOP_Y, CONTENT_WIDTH, 9999.0);
		        
		drawRect.size = circle.size;
        
		[circle.contentString drawInRect:drawRect withFont:mainFont];
		
		// Draw flashback icon if there are photos
        if ([circle.imageUrl count] >0) {
            icon = [delg.cachedImages objectAtIndex:3];
            point = CGPointMake(boundsX+19.5, CONTENT_TOP_Y + circle.size.height + GENERIC_MARGIN + GENERIC_MARGIN);
            [icon drawAtPoint:point];
		}
        
		//that's it
	}
}


- (void)dealloc
{
    [images removeAllObjects];
    [images release];
    [userImage release];
    [circle release];
    [super dealloc];
}

@end

//
//  EncounterView.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/23/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "EncounterView.h"
#import "HJManagedImageV.h"
#import "User.h"
#import "kaya_meetAppDelegate.h"

#define UIColorFromRGB(rgbValue) [UIColor \
	 colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
	 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
	 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
//usage
//UIColor color = UIColorFromRGB(0xF7F7F7);

#define GENERIC_MARGIN			5
#define	PIC_WIDTH				47

#define NAME_TOP_X				(GENERIC_MARGIN+GENERIC_MARGIN+PIC_WIDTH)
#define	NAME_TOP_WIDTH			205

#define MAIN_FONT_SIZE			12
#define MIN_MAIN_FONT_SIZE		10
#define SECONDARY_FONT_SIZE		10
#define MIN_SECONDARY_FONT_SIZE 10

@implementation EncounterView
@synthesize nameString;
@synthesize greetingString;
@synthesize pic;
@synthesize userImage;
@synthesize uID;

- (void)setPeerName:(NSString *)newNameString
             peerId:(NSInteger)uid
		   greeting:(NSString *)newGreetingString
			 picImage:(UIImage *)newPic
				row:(NSInteger)newRow
{
	self.nameString = newNameString;
	self.greetingString = newGreetingString;
	self.pic = newPic;
	row = newRow;
    uID = uid;
    // assume this is called only once for now
    
    //set the user image url
    kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
    User *user = [User userWithId:uid];
    
    [userImage clear];
	userImage.url = [NSURL URLWithString:[user.profileImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	userImage.oid = [NSString stringWithFormat:@"user_%d",user.userId];
	[delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:userImage waitUntilDone:YES];

	[self setNeedsDisplay];
}

- (void)dealloc {
	[nameString release];
	[pic release];
	
    [super dealloc];
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
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	
	//define layout
	
	// Font for name
	UIFont *nameFont = [UIFont boldSystemFontOfSize:12];
	
	// Color and font for the main text items
	UIColor *mainTextColor = nil;
	UIFont *mainFont = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
	
	// Color and font for the secondary text items
	UIColor *secondaryTextColor = nil;
	//UIFont *secondaryFont = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];
	
	mainTextColor = [UIColor blackColor];
	secondaryTextColor = [UIColor darkGrayColor];
	self.backgroundColor = [UIColor whiteColor];
	
	CGRect contentRect = self.bounds;
	
	if (row==0) {
		[[UIColor whiteColor] set];
		UIRectFill(contentRect);
	}
	else {
		[[UIColor whiteColor] set];
		UIRectFill(contentRect);
	}
	
	//we will never edit
	if (1) {
		CGFloat boundsX = contentRect.origin.x;
		CGPoint point;
		
		//CGFloat actualFontSize;
		//CGSize size;
		
		// Set the color for the main text items.
		[mainTextColor set];
		
		if (row!=0) {
			//boundsX = boundsX + 24.0;
		}
		// Draw the picture
		point = CGPointMake(boundsX+GENERIC_MARGIN, GENERIC_MARGIN);
		
		[pic drawAtPoint:point];
        
		
		// Draw name
		point = CGPointMake(boundsX + NAME_TOP_X, GENERIC_MARGIN);
		[nameString drawAtPoint:point 
					   forWidth:NAME_TOP_WIDTH 
					   withFont:nameFont 
					minFontSize:MIN_MAIN_FONT_SIZE
				 actualFontSize:NULL 
				  lineBreakMode:UILineBreakModeTailTruncation 
			 baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		
		// Draw greeting
		point = CGPointMake(boundsX + NAME_TOP_X, GENERIC_MARGIN+24);
		[greetingString drawAtPoint:point 
						   forWidth:NAME_TOP_WIDTH 
						   withFont:mainFont 
						minFontSize:MAIN_FONT_SIZE
					 actualFontSize:NULL 
					  lineBreakMode:UILineBreakModeTailTruncation 
				 baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		
		//that's it
	}
}


@end

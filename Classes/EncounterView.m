//
//  EncounterView.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/23/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "EncounterView.h"

#define UIColorFromRGB(rgbValue) [UIColor \
	 colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
	 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
	 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
//usage
//UIColor color = UIColorFromRGB(0xF7F7F7);

@implementation EncounterView
@synthesize nameString;
@synthesize greetingString;
@synthesize pic;

- (void)setPeerName:(NSString *)newNameString
		   greeting:(NSString *)newGreetingString
			 picImage:(UIImage *)newPic
				row:(NSInteger)newRow
{
	self.nameString = newNameString;
	self.greetingString = newGreetingString;
	self.pic = newPic;
	row = newRow;
	[self setNeedsDisplay];
}

- (void)dealloc {
	[nameString release];
	[pic release];
	
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
	
	//define layout
#define GENERIC_MARGIN			5
#define	PIC_WIDTH				47
	
#define NAME_TOP_X				(GENERIC_MARGIN+GENERIC_MARGIN+PIC_WIDTH)
#define	NAME_TOP_WIDTH			205
	
#define MAIN_FONT_SIZE			12
#define MIN_MAIN_FONT_SIZE		10
#define SECONDARY_FONT_SIZE		10
#define MIN_SECONDARY_FONT_SIZE 10
	
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
			boundsX = boundsX + 24.0;
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

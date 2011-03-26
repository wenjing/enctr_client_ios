//
//  EncounterCell.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/23/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "EncounterCell.h"
#import "EncounterView.h"

@implementation EncounterCell
@synthesize encounterView;

//we customize the initWithStyle method
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		
		CGRect cvFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		encounterView = [[EncounterView alloc] initWithFrame:cvFrame];
		encounterView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:encounterView];
	}
	return self;
}

- (void)setPeerName:(NSString *)peerName 
		   greeting:(NSString *)greetingText 
			peerPic:(UIImage *)peerPic 
				row:(NSInteger)peerRow {
	row = peerRow;
	//we just pass these to the view
	[encounterView setPeerName:peerName
					  greeting:greetingText
					  picImage:peerPic
						   row:peerRow];
}

//tell view to draw
- (void)redisplay {
	[encounterView setNeedsDisplay];
}


- (void)dealloc {
	[encounterView release];
    [super dealloc];
}


@end

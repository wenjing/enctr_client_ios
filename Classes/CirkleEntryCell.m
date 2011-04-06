//
//  CirkleEntryCell.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/27/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirkleEntryCell.h"
#import "CirkleEntryView.h"

@implementation CirkleEntryCell
@synthesize circleView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        // Create a circle view and add it as a subview of self's contentView.
		CGRect cvFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		// the initWithFrame is standard - I think it should just work
		circleView = [[CirkleEntryView alloc] initWithFrame:cvFrame];
		circleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:circleView];
    }
    return self;
}

- (void)setCircle:(CirkleSummary *)aCircle {
    circleView.circle = aCircle;
}

- (CGSize)getSize {
    return circleView.size;
}

//pass this to view
- (void)redisplay {
	[circleView setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [circleView release];
    [super dealloc];
}

@end

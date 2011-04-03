//
//  CirkleDetailCell.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/30/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirkleDetailCell.h"


@implementation CirkleDetailCell
@synthesize circleDetailView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        // Create a circle detail view and add it as a subview of self's contentView.
		CGRect cvFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		// the initWithFrame is standard - I think it should just work
		circleDetailView = [[CirkleDetailView alloc] initWithFrame:cvFrame];
		circleDetailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:circleDetailView];
    }
    return self;
}

- (void)setCircleDetail:(CirkleDetail *)aCircleDetail {
    circleDetailView.circleDetail = aCircleDetail;
}

- (NSInteger)getSize {
    return [circleDetailView getSize];
}

//pass this to view
- (void)redisplay {
	[circleDetailView setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [circleDetailView release];
    [super dealloc];
}

@end

//
//  TimelineTopicViewCell.m
//  Cirkle
//
//  Created by Jun Li on 2/25/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "TimelineEncounterViewCell.h"
@implementation TimelineEncounterViewCell

@synthesize userNameLabel, messageView, timeLabel, cirkleLabel;
@synthesize userImage, mapImage, friendsView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		// Initialization code
		userNameLabel = [[UILabel alloc] init];
		userNameLabel.textAlignment = UITextAlignmentLeft;
		userNameLabel.font = [UIFont systemFontOfSize:14];
		userNameLabel.backgroundColor = [UIColor clearColor];
		
		timeLabel = [[UILabel alloc] init];
		timeLabel.textAlignment = UITextAlignmentRight;
		timeLabel.font = [UIFont systemFontOfSize:11];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.textColor = [UIColor grayColor];
		cirkleLabel = [[UILabel alloc] init];
		cirkleLabel.textAlignment = UITextAlignmentLeft;
		cirkleLabel.font = [UIFont systemFontOfSize:11];
		cirkleLabel.backgroundColor = [UIColor clearColor];
		cirkleLabel.textColor = [UIColor grayColor];

		messageView = [[UILabel alloc] init];
		messageView.textAlignment = UITextAlignmentLeft;
		messageView.font = [UIFont systemFontOfSize:14];
		messageView.backgroundColor = [UIColor clearColor];
		
		userImage = [[HJManagedImageV alloc] initWithFrame:CGRectZero];
		userImage.tag = 999;
		
		mapImage = [[HJManagedImageV alloc] initWithFrame:CGRectZero];
		mapImage.tag = 998;

		friendsView = [[UIView alloc] initWithFrame:CGRectZero];
		
		[self.contentView addSubview:userNameLabel];
		[self.contentView addSubview:timeLabel];
		[self.contentView addSubview:messageView];
		[self.contentView addSubview:userImage];
		[self.contentView addSubview:mapImage];
		[self.contentView addSubview:friendsView];
		
		self.backgroundColor = [UIColor whiteColor];
		// self.backgroundView = [[[UACellBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
		self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		//	[(UACellBackgroundView *)self.backgroundView setPosition:UACellBackgroundViewPositionMiddle];
		
		[userNameLabel release];
		[timeLabel release];
		[messageView release];
		[userImage release];
		[mapImage release];
		[friendsView release];
	}
    return self;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
	
	CGRect frame;
	frame = CGRectMake(boundsX+5,5,47,47);
	userImage.frame = frame ;
	
	frame = CGRectMake(boundsX+60,5, 140,27) ;
	userNameLabel.frame = frame;
	frame = CGRectMake(boundsX+60,27,140,47) ;
	cirkleLabel.frame = frame;
	
	frame = CGRectMake(boundsX+220, 22, 80, 30);
	timeLabel.frame = frame;
	
	frame = CGRectMake(boundsX+57,57,245,123);
	mapImage.frame = frame;
	
	frame = CGRectMake(boundsX+57,185,250,50);
	messageView.frame = frame;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void) update 
{
}


- (void)dealloc {
    [super dealloc];
}


@end

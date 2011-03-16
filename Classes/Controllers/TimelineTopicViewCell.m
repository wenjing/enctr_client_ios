//
//  TimelineTopicViewCell.m
//  Cirkle
//
//  Created by Jun Li on 2/25/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "TimelineTopicViewCell.h"
#import "Timeline.h"
#import "UIImage+RoundedCorner.h"
#import <QuartzCore/QuartzCore.h>

@implementation TimelineTopicViewCell

@synthesize userNameLabel, messageView, timeLabel, cirkleLabel;
@synthesize userImage, topicImage;


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
		
		messageView = [[UILabel alloc] init];
		messageView.textAlignment = UITextAlignmentLeft;
		messageView.font = [UIFont systemFontOfSize:14];
		messageView.backgroundColor = [UIColor clearColor];

		userImage = [[HJManagedImageV alloc] initWithFrame:CGRectZero ];
		userImage.tag = 999;		
		userImage.callbackOnSetImage = self;
		
		topicImage = [[HJManagedImageV alloc] initWithFrame:CGRectZero];
		topicImage.tag = 998;

		[self.contentView addSubview:userNameLabel];
		[self.contentView addSubview:timeLabel];
		[self.contentView addSubview:messageView];
		[self.contentView addSubview:userImage];
		[self.contentView addSubview:topicImage];
		
		//self.backgroundView = [[[UACellBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
		self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		//	[(UACellBackgroundView *)self.backgroundView setPosition:UACellBackgroundViewPositionMiddle];
		
		[userNameLabel release];
		[timeLabel release];
		[messageView release];
		[userImage release];
		[topicImage release];
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

	/*
	
	frame = CGRectMake(boundsX+57,57,245,245);
	topicImage.frame = frame;
	
	frame = CGRectMake(boundsX+57,307,250,50);
	messageView.frame = frame;
	 */
}


- (void)update:(Timeline *)tl
{
	CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;

	if ( tl.img_url == nil ){
		topicImage.frame = CGRectZero;
		CGRect frame = CGRectMake(boundsX+57,57,250,50) ;
		messageView.frame = frame;
		// messageView.backgroundColor = [UIColor redColor];
	}
	else {
		topicImage.frame  = CGRectMake(boundsX+57,57,245,245);
		messageView.frame = CGRectMake(boundsX+57,307,250,50);
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void) managedImageSet:(HJManagedImageV*)mi
{
	CALayer *ly = [mi.imageView layer];
	[ly setMasksToBounds:YES];
	[ly setCornerRadius:5.0];
}

- (void) managedImageCancelled:(HJManagedImageV *)mi
{
}

- (void)dealloc {
    [super dealloc];
}


@end

//
//  FriendViewCell.m
//  kaya_meet
//
//  Created by Jun Li on 12/25/10.
//

#import <QuartzCore/QuartzCore.h>
#import "FriendViewCell.h"
#import "UACellBackgroundView.h"

@implementation FriendViewCell

@synthesize nameLabel ,friendImageView ;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		// Initialization code
		nameLabel = [[UILabel alloc] init];
		nameLabel.textAlignment = UITextAlignmentCenter;
		nameLabel.font = [UIFont systemFontOfSize:15];
		friendImageView = [[HJManagedImageV alloc] init];
		friendImageView.tag = 999;
		
		nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:nameLabel];
		[self.contentView addSubview:friendImageView];
		self.backgroundView = [[[UACellBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
		self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		//	[(UACellBackgroundView *)self.backgroundView setPosition:UACellBackgroundViewPositionMiddle];
		
		[nameLabel release];
		[friendImageView release];
	}
	return self;
}

/**
 * Cell layout
 */
- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
	
	CGRect frame;
	
	frame= CGRectMake(boundsX+5 ,5,  47, 47);
	friendImageView.frame = frame;
	
	frame= CGRectMake(boundsX+57,5, 164, 47);
	nameLabel.frame = frame;
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

- (void)dealloc {
//	[friendImageView release] ;
//	[nameLabel release] ;
    [super dealloc];
}

@end

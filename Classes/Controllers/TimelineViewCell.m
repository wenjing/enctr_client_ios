//
//
#import "kaya_meetAppDelegate.h"
#import "TimelineViewCell.h"

@implementation TimelineViewCell

@synthesize _timeline;

+ (void)initialize
{
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		userImage  = [[HJManagedImageV alloc] init];
		topicImage = [[HJManagedImageV alloc] init];
		[self.contentView addSubview:userImage];
		[self.contentView addSubview:topicImage];
		[userImage release];
		[topicImage release];
	}	
	return self ;
}

- (void)dealloc
{
	[_timeline release];
    [super dealloc];
}

- (void)setTimeline:(Timeline *)tl
{
	if ( _timeline != tl ) {
		[_timeline  release];
		_timeline  = [tl retain];
	}
	[self setNeedsDisplay]; 
}

- (void)updateProfileImage
{
	User *u = [User userWithId:_timeline.uid];
	userImage.url = [NSURL URLWithString:[u.profileImageUrl 
						stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	userImage.oid = [NSString stringWithFormat:@"user_%d",u.userId];
	kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
	[delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:userImage waitUntilDone:YES];
	[self setNeedsDisplay]; 
}

- (void)updateTopicIMage
{
	CGFloat width, heigh;
	if ( _timeline.type == TIMELINE_TOPIC && _timeline.img_url != nil ) {
		width = 254;
		heigh = 254;
	}else if ( _timeline.type == TIMELINE_ENCOUNTER) {
		width = 130;
		heigh = 130;
	}else {
		width = 0 ;
		heigh = 0 ;
	}
	topicImage.frame = CGRectMake(57,57,width,heigh);
	if ( _timeline.img_url != nil ) {
		topicImage.url = [NSURL URLWithString:_timeline.img_url] ;
		kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
		[delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:topicImage waitUntilDone:YES];
	}
	[self setNeedsDisplay]; 
}

- (void)prepareForReuse
{
    [super prepareForReuse];
	[userImage clear];
	[topicImage clear];
}

- (void)drawContentView:(CGRect)r
{
	User *u = [User userWithId:_timeline.uid];
	CGContextRef context = UIGraphicsGetCurrentContext();

	UIColor *backgroundColor = [UIColor whiteColor];
	UIColor *textColor = [UIColor blackColor];
	
	if(self.selected)
	{
		backgroundColor = [UIColor clearColor];
		textColor = [UIColor whiteColor];
	}
	[backgroundColor set];
	CGContextFillRect(context, r);
	[textColor set];
	[u.name drawInRect:CGRectMake(60,5, 140, 27) withFont:[UIFont systemFontOfSize:14]];
	[[_timeline timestamp] drawInRect:CGRectMake(220, 22, 80, 30) withFont:[UIFont systemFontOfSize:11]];
	
/*	CGPoint p;
	p.x = 60;
	p.y = 5;
	CGSize s = [Topic drawAtPoint:p withFont:textFontSize];
	p.x += s.width + 6; // space between words
	p.y += s.height + 5;
	[Topic drawAtPoint:p withFont:lastTextFont]; */
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    self.backgroundColor = self.contentView.backgroundColor;
	userImage.frame = CGRectMake(5,5,47,47);
}

@end


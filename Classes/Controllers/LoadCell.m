//
//  LoadCell.m
//
//  For transforming purpose
//

#import "LoadCell.h"

static NSString *sLabels[] = {
    @"Load all stored meets...",
    @"Loading...",
    @"Send request...",
    @"Meet request has been sent.",
};

@implementation LoadCell

@synthesize spinner;
@synthesize type;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    // name label
    label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor blueColor];
    label.highlightedTextColor = [UIColor redColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.numberOfLines = 1;
    label.textAlignment = UITextAlignmentCenter;    
    label.frame = CGRectMake(0, 0, 320, 47);
    [self.contentView addSubview:label];
    
    spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    [self.contentView addSubview:spinner];
	return self;
}

- (void)setType:(loadCellType)aType
{
    type = aType;
    label.text = sLabels[type];
    [spinner startAnimating];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = [label textRectForBounds:CGRectMake(0, 0, 320, 48) limitedToNumberOfLines:1];
    spinner.frame = CGRectMake(bounds.origin.x + bounds.size.width + 4, (self.frame.size.height / 2) - 8, 16, 16);
    label.frame   = CGRectMake(0, 0, 320, self.frame.size.height - 1);
}

- (void)dealloc {
	[super dealloc];
}

@end

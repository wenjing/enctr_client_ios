//
//  LoadCell.m
//
//  For transforming purpose
//

#import "LoadCell.h"

static NSString *sLabels[] = {
    @"Get meet from server",
    @"Load more meet",
    @"Loading...",
    @"Meet request has been sent.",
};

@implementation LoadCell

@synthesize spinner;
@synthesize type;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    // name label
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    label.highlightedTextColor = [UIColor blueColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.numberOfLines = 1;
    label.textAlignment = UITextAlignmentCenter;    
    label.frame = CGRectMake(0, 0, 320, 47);
    [self.contentView addSubview:label];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.contentView addSubview:spinner];
	
	[label release];
	[spinner release];
	
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

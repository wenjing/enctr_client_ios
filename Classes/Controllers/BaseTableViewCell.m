// BaseTableViewCell.m
//

#import "BaseTableViewCell.h"

@interface BaseTableViewCellView : UIView
@end

@implementation BaseTableViewCellView

- (void)drawRect:(CGRect)r
{
	[(BaseTableViewCell *)[self superview] drawContentView:r];
}

@end

@implementation BaseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style  reuseIdentifier:reuseIdentifier])
    {
	contentView = [[BaseTableViewCellView alloc] initWithFrame:CGRectZero];
	contentView.opaque = YES;
	[self addSubview:contentView];
	[contentView release];
    }
    return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)setFrame:(CGRect)f
{
	[super setFrame:f];
	CGRect b = [self bounds];
	b.size.height -= 1; // leave room for the seperator line
	[contentView setFrame:b];
}

- (void)setNeedsDisplay
{
	[super setNeedsDisplay];
	[contentView setNeedsDisplay];
}

- (void)drawContentView:(CGRect)r
{
	// subclasses should implement this
}

@end


// BaseTableViewCell.h

#import <UIKit/UIKit.h>

// to use: subclass BaseTableViewCell and implement -drawContentView:

@interface BaseTableViewCell : UITableViewCell
{
	UIView *contentView;
}

- (void)drawContentView:(CGRect)r; // subclasses should implement

@end

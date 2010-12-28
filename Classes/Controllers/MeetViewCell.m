//
// MeetViewCell.m
//

#import "MeetViewCell.h"
#import "UACellBackgroundView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MeetViewCell

@synthesize primaryLabel ,
            secondaryLabel ,
            meetImageView ;

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * initialization
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
      // Initialization code
      primaryLabel = [[UILabel alloc]init];
      primaryLabel.textAlignment = UITextAlignmentLeft;
      primaryLabel.font = [UIFont systemFontOfSize:12];
	  primaryLabel.backgroundColor = [UIColor clearColor];
      secondaryLabel = [[UILabel alloc]init];
      secondaryLabel.textAlignment = UITextAlignmentLeft;
      secondaryLabel.font = [UIFont systemFontOfSize:9];
	  secondaryLabel.backgroundColor = [UIColor clearColor];
      meetImageView = [[UIImageView alloc]init];
      
      [self.contentView addSubview:primaryLabel];
      [self.contentView addSubview:secondaryLabel];
      [self.contentView addSubview:meetImageView];
	   self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	   self.backgroundView = [[[UACellBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
	   [(UACellBackgroundView *)self.backgroundView setPosition:UACellBackgroundViewPositionMiddle];
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
  
  frame= CGRectMake(boundsX+5 ,5, 35, 35);
  meetImageView.frame = frame;
  
  frame= CGRectMake(boundsX+40 ,5, 200, 25);
  primaryLabel.frame = frame;
  
  frame= CGRectMake(boundsX+45 ,25, 200, 35);
  secondaryLabel.frame = frame;
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
  [primaryLabel release];
  [secondaryLabel release];
  [meetImageView release];
  [super dealloc];
}


@end

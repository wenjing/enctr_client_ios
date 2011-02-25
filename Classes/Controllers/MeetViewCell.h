//
// MeetViewCell.h
//

#import <UIKit/UIKit.h>
#import "HJManagedImageV.h"


@interface MeetViewCell : UITableViewCell {
  UILabel *primaryLabel;
  UILabel *secondaryLabel;
  HJManagedImageV *meetImageView;
}

@property(nonatomic,retain)UILabel *primaryLabel;

@property(nonatomic,retain)UILabel *secondaryLabel;

@property(nonatomic,retain)HJManagedImageV *meetImageView;

@end

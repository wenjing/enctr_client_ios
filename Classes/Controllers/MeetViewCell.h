//
// MeetViewCell.h
//

#import <UIKit/UIKit.h>



@interface MeetViewCell : UITableViewCell {
  UILabel *primaryLabel;
  UILabel *secondaryLabel;
  UIImageView *meetImageView;
}

@property(nonatomic,retain)UILabel *primaryLabel;

@property(nonatomic,retain)UILabel *secondaryLabel;

@property(nonatomic,retain)UIImageView *meetImageView;

@end

//
//  FriendViewCell.h
//  kaya_meet
//
//  Created by Jun Li on 12/25/10.
//

#import <UIKit/UIKit.h>
#import "HJManagedImageV.h"



@interface FriendViewCell : UITableViewCell {
	UILabel *nameLabel;
	HJManagedImageV *friendImageView;
}

@property(nonatomic,retain)UILabel *nameLabel;
@property(nonatomic,retain)HJManagedImageV *friendImageView;

@end

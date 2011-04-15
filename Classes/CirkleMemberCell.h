//
//  CirkleMemberCell.h
//  Cirkle
//
//  Created by Wenjing Chu on 4/13/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJManagedImageV.h"
#import "User.h"

@interface CirkleMemberCell : UITableViewCell {
    UILabel *primaryLabel;
    UILabel *secondaryLabel;
    HJManagedImageV *userImageView;
}
@property(nonatomic,retain) UILabel *primaryLabel;
@property(nonatomic,retain) UILabel *secondaryLabel;
@property(nonatomic,retain) HJManagedImageV *userImageView;

@end

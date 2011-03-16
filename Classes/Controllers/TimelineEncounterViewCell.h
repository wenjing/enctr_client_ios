//
//  TimelineTopicViewCell.h
//  Cirkle
//
//  Created by Jun Li on 2/25/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJManagedImageV.h"
#import "UACellBackgroundView.h"

@interface TimelineEncounterViewCell : UITableViewCell {
	UILabel *userNameLabel,*cirkleLabel;
	UILabel *messageView  ;
	UILabel *timeLabel	  ;
	HJManagedImageV *userImage;
	HJManagedImageV *mapImage;
	UIView  *friendsView;
}
@property(nonatomic,retain)UILabel *userNameLabel, *messageView, *timeLabel, *cirkleLabel;
@property(nonatomic,retain)HJManagedImageV *userImage, *mapImage;
@property(nonatomic,retain)UIView *friendsView;



@end

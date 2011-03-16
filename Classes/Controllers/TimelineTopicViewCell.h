//
//  TimelineTopicViewCell.h
//  Cirkle
//
//  Created by Jun Li on 2/25/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJManagedImageV.h"
#import "HJManagedImageVDelegate.h"

#import "UACellBackgroundView.h"
#import "Timeline.h"

@interface TimelineTopicViewCell : UITableViewCell <HJManagedImageVDelegate> {
	UILabel *userNameLabel, *cirkleLabels;
	UILabel *messageView  ;
	UILabel *timeLabel	  ;
	HJManagedImageV *userImage;
	HJManagedImageV *topicImage;
}
@property(nonatomic,retain)UILabel *userNameLabel, *messageView, *timeLabel, *cirkleLabel;
@property(nonatomic,retain)HJManagedImageV *userImage, *topicImage;


-(void) update:(Timeline*)tl ;
@end

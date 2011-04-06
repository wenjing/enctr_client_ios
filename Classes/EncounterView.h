//
//  EncounterView.h
//  Cirkle
//
//  Created by Wenjing Chu on 3/23/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HJManagedImageV.h"
#import "HJManagedImageVDelegate.h"

@interface EncounterView : UIView {
	NSString	*nameString;
    NSInteger   uID;
	NSString	*greetingString;
	UIImage		*pic;
    HJManagedImageV *userImage;
	NSInteger	row;
}
@property (nonatomic, retain) NSString *nameString;
@property (nonatomic, retain) NSString *greetingString;
@property (nonatomic, retain) UIImage *pic;
@property (nonatomic, retain) HJManagedImageV *userImage;
@property (nonatomic) NSInteger uID;

//use this method to set
- (void)setPeerName:(NSString *)newNameString
             peerId:(NSInteger) uid
		   greeting:(NSString *)newGreetingString
		   picImage:(UIImage *)newPic
				row:(NSInteger)newRow;

@end

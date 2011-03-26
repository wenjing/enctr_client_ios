//
//  EncounterView.h
//  Cirkle
//
//  Created by Wenjing Chu on 3/23/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EncounterView : UIView {
	NSString	*nameString;
	NSString	*greetingString;
	UIImage		*pic;
	NSInteger	row;
}
@property (nonatomic, retain) NSString *nameString;
@property (nonatomic, retain) NSString *greetingString;
@property (nonatomic, retain) UIImage *pic;

//use this method to set
- (void)setPeerName:(NSString *)newNameString
		   greeting:(NSString *)newGreetingString
		   picImage:(UIImage *)newPic
				row:(NSInteger)newRow;

@end

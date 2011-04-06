//
//  EncounterCell.h
//  Cirkle
//
//  Created by Wenjing Chu on 3/23/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EncounterView;

@interface EncounterCell : UITableViewCell {
	EncounterView *encounterView;
	NSInteger row;
}
@property (nonatomic, retain) EncounterView *encounterView;

- (void)redisplay;
- (void)setPeerName:(NSString *)peerName 
             peerId:(NSInteger) peerId
		   greeting:(NSString *)greetingText
			peerPic:(UIImage *)peerPic 
				row:(NSInteger)peerRow;

@end

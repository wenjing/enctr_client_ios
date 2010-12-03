//
//  MeetDataSource.h
//

#import <UIKit/UIKit.h>
#import "KYMeet.h"
#import "LoadCell.h"

@interface MeetDataSource : NSObject {
	NSMutableArray*			meets;
    LoadCell*               loadCell ;
    CGPoint                 contentOffset;
}

@property(nonatomic, readonly)  NSMutableArray* meets;
@property(nonatomic, assign)	CGPoint contentOffset;

- (int)restoreMeets:(MeetType)type all:(BOOL)flag;

- (int) countMeets;
- (void)appendMeet:(KYMeet*)meet;
- (void)insertMeet:(KYMeet*)meet atIndex:(int)index;

- (KYMeet*)meetAtIndex:(int)i;
- (KYMeet*)meetById:(sqlite_int64)id;
- (KYMeet*)lastMeet;

- (void)removeMeet:(KYMeet*)meet;
- (void)removeMeetAtIndex:(int)index;
- (void)removeLastMeet;
- (void)removeAllMeets;

- (int)indexOfObject:(KYMeet*)meet;
- (void)sortByDate;

- (id)  init  ;
- (void)removeAllMeets;

@end

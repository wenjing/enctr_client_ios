
//
//  Bluetooth.h
//  Bluetooth
//

#import <GameKit/GameKit.h>

typedef enum {
    BT_PEER=0,
    BT_HOST,
    BT_ADD,
	BT_FREE,
    BT_MODE
} KAYA_MEET_BT_TYPE;


@interface BluetoothConnect : NSObject<GKPeerPickerControllerDelegate, GKSessionDelegate>  {
//	GKPeerPickerController  *picker  ;
	GKSession				*session ;
	NSMutableArray			*peerList;
	int					     aNumber ;
	NSTimer					*timer   ;
	id						 delegate;
	KAYA_MEET_BT_TYPE		 mode    ;
	NSMutableArray			*devNames;
}

//@property (nonatomic, retain) GKPeerPickerController *picker;
@property (nonatomic, retain) GKSession *session;
@property (nonatomic, retain) NSMutableArray *peerList, *devNames;
@property (nonatomic, readwrite) KAYA_MEET_BT_TYPE mode;

- (id) initWithDelegate:(id)aDelegate;
- (void)startPeer;
- (void)startPeer:(uint64_t)  meet_id;
- (void)startHost:(NSString *)name withId:(uint64_t)meet_id;
- (void) stopPeer;
- (int) numberOfPeers;
- (void) reset;

// utilities

- (int)findPeerName:(NSString*)name;
- (NSString *)getPeerNameList ;
- (NSString *)findHost ;
- (NSString *)findMeet ;
- (int)countField:(NSString *)str;
- (void)getDisplayNames:(NSString *)str ;
- (NSString *)getDisplayName ;
@end

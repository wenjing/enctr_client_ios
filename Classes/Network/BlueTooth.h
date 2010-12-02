
//
//  Bluetooth.h
//  Bluetooth
//

#import <GameKit/GameKit.h>

@interface BluetoothConnect : NSObject<GKPeerPickerControllerDelegate, GKSessionDelegate>  {
	GKPeerPickerController  *picker  ;
	GKSession				*session ;
	NSMutableArray			*peerList;
	int					     aNumber ;
	NSTimer					*timer   ;
	id						 delegate;
}

@property (nonatomic, retain) GKPeerPickerController *picker;
@property (nonatomic, retain) GKSession *session;
@property (nonatomic, retain) NSMutableArray *peerList;

- (id) initWithDelegate:(id)aDelegate;
- (void)startPeer;
- (void) stopPeer;
- (void) loadPeerList;
- (int) numberOfPeers;
- (void) reset;
@end

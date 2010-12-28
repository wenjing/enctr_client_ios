
//
//  Bluetooth.m
//  Bluetooth
//

#import "kaya_meetAppDelegate.h"
#import "Bluetooth.h"

@interface NSObject (BluetoothConnectDelegate)
- (void)BluetoothDidUpdate  :(BluetoothConnect*)manager peer:(NSString*)peerID;
- (void)BluetoothDidFinished:(BluetoothConnect*)manager;
@end

#define BLUETOOTH_TIMEOUT	 5
#define BLUETOOTH_MAX_FRIEND 3

@implementation BluetoothConnect

@synthesize picker;
@synthesize session;
@synthesize peerList;

- (int) numberOfPeers{
	return aNumber ;
}

- (void) startPeer
{
	User *user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
    
	if (!session) {
        session = [[GKSession alloc] initWithSessionID:@"kaya_meet_app"
                                           displayName:[NSString stringWithFormat:@"%@:%d",user.name,user.userId]
                                           sessionMode:GKSessionModePeer];
        session.delegate = self;
        [session setDataReceiveHandler:self withContext:nil];
        session.available = YES;
		NSLog(@"start Peer id is %@ name is %@", session.peerID, [session displayNameForPeer:session.peerID]);
    }
	timer = [NSTimer scheduledTimerWithTimeInterval:BLUETOOTH_TIMEOUT
                                             target:self
                                           selector:@selector(bluetoothDidTimeout:userInfo:)
                                           userInfo:nil
                                            repeats:false];
}

-(void) bluetoothDidTimeout:(NSTimer*)aTimer userInfo:(id)userInfo
{
	timer = nil ;
	[delegate BluetoothDidFinished:self];
	[self stopPeer];
}

- (void) stopPeer
{
    // Set up the session for the next connection
    //
    [session disconnectFromAllPeers];
	session.available = NO;
	[session setDataReceiveHandler: nil withContext: nil];
	session.delegate = nil;
	[session release];
}

- (id)initWithDelegate:(id)aDelegate {
	[super init];
	delegate = aDelegate;
	// allocate and setup the peer picker controller
	// not use the picker as for now
//	picker  = [[GKPeerPickerController alloc] init];
//	picker.delegate = self;
//	picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
//	[picker show];
	peerList = [[NSMutableArray alloc] init];
	aNumber = 0 ;
	session = nil;
	return self;
}

- (void) reset {
	aNumber = 0 ;
	session = nil;
	[peerList removeAllObjects] ;
}

//- (void)peerPickerController:(GKPeerPickerController *)picker didSelectConnectionType:(GKPeerPickerConnectionType)type {
//}

- (GKSession *) peerPickerController:(GKPeerPickerController *)picker
	sessionForConnectionType:(GKPeerPickerConnectionType)type {
	if ( session == nil ) {
		session = [[GKSession alloc] initWithSessionID:@"kaya_meet_app"  displayName:nil sessionMode:GKSessionModePeer];
		session.delegate = self;
		[session setDataReceiveHandler:self withContext:nil];
        session.available = YES;
	}
	return session;
}

- (void) loadPeerList
{
	if (peerList == nil ) 
		peerList = [[NSMutableArray alloc] initWithArray:[session peersWithConnectionState:GKPeerStateAvailable]];
}

- (void)session:(GKSession *)aSession peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	BOOL peerChanged = NO;
	switch (state) {
		case GKPeerStateAvailable:
                if (peerList) {
					//[peerList addObject:peerID];
					[peerList addObject:[aSession displayNameForPeer:peerID]];
					//	[session connectToPeer:peerID withTimeout:10];
					peerChanged = YES;
					aNumber ++ ;
                }
			if ([delegate respondsToSelector:@selector(BluetoothDidUpdate:peer:)]) {
				[delegate BluetoothDidUpdate:self peer:peerID];
			}
			break;

		case GKPeerStateUnavailable:
                if (peerList) {
             //         [peerList removeObject:peerID];
                        peerChanged = YES;
                }
                break;

		case GKPeerStateConnected:
			   [self.session setDataReceiveHandler :self withContext:nil];
			// [self mySendData]; start off by sending data upon connection
				break;
		case GKPeerStateDisconnected:
				break;
	}
	if ( aNumber == BLUETOOTH_MAX_FRIEND ){
		[timer invalidate];
		[delegate BluetoothDidFinished:self];
		[self stopPeer];
	}
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	NSError *error = nil;
	[self.session acceptConnectionFromPeer:peerID error:&error];
	if (error)
		NSLog(@"%@",error);
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	NSLog(@"%@",error);
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectToPeer:(NSString *)peerID {
    NSLog(@"connection was successful! \n");
}


- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
	NSLog(@"connection attempt was canceled\n");
}


- (void)mySendData {
	// allocate the NSData
	aNumber++;
	NSData *myData = [[NSData alloc] initWithBytes:&aNumber length:sizeof(int)];
	[session sendDataToAllPeers :myData withDataMode:GKSendDataReliable error:nil];
	NSLog(@"send data: %i\n", aNumber);
	[myData autorelease];
}


- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
	// Read the bytes in data and perform an application-specific action, then free the NSData object
	[data getBytes:&aNumber length:sizeof(int)];
	NSLog(@"received data: %i from: %s\n", aNumber, [peer UTF8String]);
	[self mySendData];
}


- (void)dealloc
{
	if (timer)    [timer invalidate];
	[picker release];
	[self stopPeer];
	[peerList release];
	[super dealloc];
}

@end

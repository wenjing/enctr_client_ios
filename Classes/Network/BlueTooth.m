
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
#define BLUETOOTH_SERVER_TIMEOUT 3600
#define BLUETOOTH_MAX_FRIEND 3

@implementation BluetoothConnect

//@synthesize picker;
@synthesize session;
@synthesize devNames, peerList, mode;

- (int) numberOfPeers{
	return aNumber ;
}

// host mode start from meet detail view.

- (void) startHost:(NSString *)name withId:(uint64_t)meet_id
{
	User *user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
    
	if (!session) {
		
        	session = [[GKSession alloc] initWithSessionID:@"oncircles"
			   displayName:[NSString stringWithFormat:@"%@:%d:%@:%ld",user.name,user.userId,name,meet_id]
			   sessionMode:GKSessionModeServer];
	}
        session.delegate = self;
        [session setDataReceiveHandler:self withContext:nil];
        session.available = YES;
	mode = BT_HOST ;

	NSLog(@"start host mode : %@", [session displayNameForPeer:session.peerID]);
	timer = [NSTimer scheduledTimerWithTimeInterval:BLUETOOTH_SERVER_TIMEOUT
                                             target:self
                                           selector:@selector(bluetoothDidTimeout:userInfo:)
                                           userInfo:nil
                                            repeats:false];
}

// peer mode start from meet list view
- (void) startPeer
{
	User *user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
    
	if (!session) {
		//first time create the session
        	session = [[GKSession alloc] initWithSessionID:@"oncircles"
			displayName:[NSString stringWithFormat:@"%@:%d",user.name,user.userId]
			sessionMode:GKSessionModePeer];
	}
        session.delegate = self;
        [session setDataReceiveHandler:self withContext:nil];
	NSLog(@"started PM session %x peer %x %@", session, session.peerID, [session displayNameForPeer:session.peerID]);
	mode = BT_PEER ;

	//turn on the session
        session.available = YES;
	//timer to stop the session
	timer = [NSTimer scheduledTimerWithTimeInterval:BLUETOOTH_TIMEOUT
                                             target:self
                                           selector:@selector(bluetoothDidTimeout:userInfo:)
                                           userInfo:nil
                                            repeats:false];
	return;
}

// start peer with meet_id from meet detail view
// name:time_id:id

- (void) startPeer:(uint64_t)meet_id
{
	time_t now;
	time(&now);
	User *user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
    
	if (!session) {
        	session = [[GKSession alloc] initWithSessionID:@"oncircles"
			   displayName:[NSString stringWithFormat:@"%@:%d_%d:%ld",user.name,now,user.userId,meet_id]
			   sessionMode:GKSessionModePeer];
	}
        session.delegate = self;
        [session setDataReceiveHandler:self withContext:nil];
        session.available = YES;
	NSLog(@"start PM session %x peer %x %@", session, session.peerID, [session displayNameForPeer:session.peerID]);
	mode = BT_ADD ;
	
	timer = [NSTimer scheduledTimerWithTimeInterval:BLUETOOTH_TIMEOUT
                                             target:self
                                           selector:@selector(bluetoothDidTimeout:userInfo:)
                                           userInfo:nil
                                            repeats:false];
	return;
}

-(void) bluetoothDidTimeout:(NSTimer*)aTimer userInfo:(id)userInfo
{
	timer = nil ;
	if ( mode != BT_HOST ) [delegate BluetoothDidFinished:self];
	[self stopPeer];
}

- (void) stopPeer
{
    // invalidate a session
    //
	NSLog(@"stop PM session %x peer %x %@", session, session.peerID, [session displayNameForPeer:session.peerID]);
    	[session disconnectFromAllPeers];
	session.available = NO;
	[session setDataReceiveHandler: nil withContext: nil];
	session.delegate = nil;
	mode=BT_FREE;
	//[session release];
}

- (void) reset {

	NSLog(@"session reset: %x peer %x %@\n", session, session.peerID, [session displayNameForPeer:session.peerID]);
	if ( mode != BT_FREE ) [self stopPeer];
	aNumber = 0 ;
	self.session = nil;
	//[session release];
	//session = nil;
	[peerList removeAllObjects]  ;
	[devNames removeAllObjects]  ;
}

- (id)initWithDelegate:(id)aDelegate {
	[super init];
	delegate = aDelegate;

	peerList = [[NSMutableArray alloc] init];
	devNames = [[NSMutableArray alloc] init];
	aNumber = 0 ;
	mode = BT_FREE;
	session = nil;
	return self;
}


- (void)session:(GKSession *)aSession peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	BOOL peerChanged = NO;
	if (mode == BT_HOST) {
		aNumber ++ ;
		return ;
	}
	switch (state) {
		case GKPeerStateAvailable:
		//we probably should do this asynchronously - send connect request regardless if this peer is real
		//we will only accept the peer if we get connected state
		NSLog(@"connecting to peer %x %@\n", peerID, [aSession displayNameForPeer:peerID]);
		[aSession connectToPeer:peerID withTimeout:0];

			if ([delegate respondsToSelector:@selector(BluetoothDidUpdate:peer:)]) {
				[delegate BluetoothDidUpdate:self peer:peerID];
			}
			break;

		case GKPeerStateUnavailable:
                if (peerList) {
			NSLog(@"reported peer unavailable %x %@\n", peerID, [aSession displayNameForPeer:peerID]);
             //         [peerList removeObject:peerID];
                        peerChanged = YES;
                }

                break;

		case GKPeerStateConnected:
			NSLog(@"peer state connected %x %@\n", peerID, [aSession displayNameForPeer:peerID]);
			   [self.session setDataReceiveHandler :self withContext:nil];

			   //now we put this peer into accepted peerList
			   [peerList addObject:[aSession displayNameForPeer:peerID]];
			   aNumber++;
			   peerChanged = YES;

			// [self mySendData]; start off by sending data upon connection
				break;

		case GKPeerStateDisconnected:
			NSLog(@"peer state disconnected %@\n", [aSession displayNameForPeer:peerID]);	
			//I am doing nothing at this time
				break;
	}
	if ( aNumber == BLUETOOTH_MAX_FRIEND ){
		[timer invalidate];
		[delegate BluetoothDidFinished:self];
		[self stopPeer];
	}
}

- (void)session:(GKSession *)aSession didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	NSError *error = nil;
	
	NSLog(@"received connection request %x %@\n", peerID, [aSession displayNameForPeer:peerID]);

	//there is only one session: self.session and aSession is the same
	if (self.session != aSession) {
		NSLog(@"What?! there are many sessions!\n");
	}
	[aSession acceptConnectionFromPeer:peerID error:&error];
	
	if (error)
		NSLog(@"error in acceptConnectionFromPeer %@",error);
}

- (void)session:(GKSession *)aSession connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	//this would be normal for phantom peers
	NSLog(@"connectionWithPeerFailed %x %@ %@" ,peerID, [aSession displayNameForPeer:peerID], error);
}


- (void)dealloc
{
	if (timer)    [timer invalidate];
//	[picker release];
	if ( mode != BT_FREE ) [self stopPeer];

	//reset won't be called, so I think we need to do these three things
	self.session =nil;
	[peerList removeAllObjects]  ;
	[devNames removeAllObjects]  ;

	[peerList release];
	[devNames release];
	[super dealloc];
}



// utility
// name:u_id
// name:u_id:host_name:meet_id
// name:u_id:meet_id
// name utility

- (NSString *)getDisplayName
{
	return [session displayNameForPeer:session.peerID];
}

- (NSString *)getPeerNameList
{
	NSMutableArray* pairs = [NSMutableArray array];
	for (int i = 0 ; i < aNumber ; i ++ ) {
		if ([self countField:[peerList objectAtIndex:i]] > 2) continue ;
		 NSRange end = [[peerList objectAtIndex:i] rangeOfString:@":"] ;
		[pairs addObject:[[peerList objectAtIndex:i] substringToIndex:end.location]];
	}
	if ( [pairs count] )
		return [pairs componentsJoinedByString:@","] ;
	return nil ;
}


- (NSString *)findHost {
	for ( int i = 0 ; i < aNumber ; i ++ ) 
	{
		if ( [self countField:[peerList objectAtIndex:i]] > 3 )
			return [peerList objectAtIndex:i] ;
	}
	return nil ;
}

- (NSString *)findMeet {
	for ( int i = 0 ; i < aNumber ; i ++ ) 
	{
		if ( [self countField:[peerList objectAtIndex:i]] == 3 )
			return [peerList objectAtIndex:i] ;
	}
	return nil ;
}

- (int) countField:(NSString *)str
{	int count = 1  ;
	int len = [str length];
	for (int i = 0 ; i < len ; i ++ ) 
		if ( [str characterAtIndex:i] == ':' ) count++;
	return count ;
}

- (void)getDisplayNames:(NSString *)str
{
	[devNames removeAllObjects];
	int start = 0;
	int len = [str length];
	NSCharacterSet* chs = [NSCharacterSet characterSetWithCharactersInString:@":"];
	
	while (start < len) {
		NSRange r = [str rangeOfCharacterFromSet:chs options:0 range:NSMakeRange(start, len-start)];
		if (r.location == NSNotFound) {
			[devNames addObject:[str substringFromIndex:start]];
			break;
		}
		if (start < r.location) {
			[devNames addObject:[str substringWithRange:NSMakeRange(start, r.location-start)]];
		}
		start = r.location + 1;
	}
}

@end

//
//  SessionManager.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/22/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "SessionManager.h"
#import "User.h"

@interface NSObject (SessionManagerDelegate)
- (void)sessionManagerDidUpdate:(NSString *)peerName;
- (void)sessionManagerDidFinish:(NSMutableArray *)peersArray;
@end

@implementation SessionManager
@synthesize session;
@synthesize peerList;
@synthesize excludeList;

- (id) initWithDelegate:(id)aDelegate {
	[super init];
	delegate = aDelegate;
	
	peerList = [[NSMutableArray alloc] init];
	
	User *user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
	
	excludeList = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%@:%d",user.name,user.userId], nil];
	
	session = nil;
	
	return self;
}

- (void) startSession:(GKSessionMode) sessionMode {
	//to be replaced later with identity from the controller
	User *user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
    
	
	session = [[GKSession alloc] initWithSessionID:@"oncircles"
									   displayName:[NSString stringWithFormat:@"%@:%d",user.name,user.userId]
									   sessionMode:sessionMode];
	
	session.delegate = self;
	
	NSLog(@"started session %x id %x name %@", session, session.peerID, [session displayNameForPeer:session.peerID]);
	
	//turn on the session
	session.available = YES;
	
	return;
}

	
- (void) stopSession {
	
	// this may be called more than once
	if (session == nil) {
		return;
	}
	
	NSLog(@"stoping session %x id %x name %@", session, session.peerID, [session displayNameForPeer:session.peerID]);
	
	[session disconnectFromAllPeers];
	
	session.available = NO;

	// call controller who must copy peerList if it wants to keep
	[delegate sessionManagerDidFinish:peerList];
	
	[peerList removeAllObjects];
	// keep exclude list
	// release session
	self.session = nil;
}

- (void)dealloc
{

	if (session) {
		[self stopSession];
	}
	
	[peerList removeAllObjects]  ;
	[excludeList removeAllObjects]  ;
	
	[peerList release];
	[excludeList release];
	[super dealloc];
}


#pragma mark -
#pragma mark SessionManager GKSession Methods

- (void)session:(GKSession *)aSession peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {

	switch (state) {
		case GKPeerStateAvailable:
			//we probably should do this asynchronously - send connect request regardless if this peer is real
			//we will only accept the peer if we get connected state
			//remove duplicates
			/* leave this out for now
			if ([peerList containsObject:[aSession displayNameForPeer:peerID]]) {
				NSLog(@"ignore duplicated peer %@\n",[aSession displayNameForPeer:peerID]);
				break;
			}*/
			if ([excludeList containsObject:[aSession displayNameForPeer:peerID]]) {
				NSLog(@"ignore excluded peer %@\n",[aSession displayNameForPeer:peerID]);
				break;
			}
			
			NSLog(@"connecting to peer %x name %@\n", peerID, [aSession displayNameForPeer:peerID]);
			
			[aSession connectToPeer:peerID withTimeout:0];

			break;
			
		case GKPeerStateUnavailable:
			
			if (peerList) {
				NSLog(@"peer unavailable %x name %@\n", peerID, [aSession displayNameForPeer:peerID]);
			}
			
			break;
			
		case GKPeerStateConnected:
			
			NSLog(@"peer state connected %x name %@\n", peerID, [aSession displayNameForPeer:peerID]);
			
			[peerList addObject:[aSession displayNameForPeer:peerID]];
			
			[delegate sessionManagerDidUpdate:[aSession displayNameForPeer:peerID]];
			
			break;
			
		case GKPeerStateDisconnected:
			
			NSLog(@"peer state disconnected %x name %@\n", peerID, [aSession displayNameForPeer:peerID]);	
			
			break;
			
		case GKPeerStateConnecting:
			//ignore
			break;
	}
	return;
}

- (void)session:(GKSession *)aSession didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	NSError *error = nil;
	
	NSLog(@"received connection request from peer %x name %@\n", peerID, [aSession displayNameForPeer:peerID]);
	
	[aSession acceptConnectionFromPeer:peerID error:&error];
	
	if (error) {
		NSLog(@"error in acceptConnectionFromPeer: %@",error);
	}
}

- (void)session:(GKSession *)aSession connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	//this would be normal for phantom peers
	NSLog(@"connectionWithPeerFailed %x name %@ : %@" ,peerID, [aSession displayNameForPeer:peerID], error);
}


@end
//
//  SessionManager.h
//  Cirkle
//
//  Created by Wenjing Chu on 3/22/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <GameKit/GameKit.h>

@interface SessionManager : NSObject <GKSessionDelegate> {
	GKSession				*session ;
    GKSessionMode           sessionMode;
    NSString                *displayName;
	NSMutableArray			*peerList;
	NSMutableArray			*excludeList;
	id						 delegate;
}
@property (nonatomic, retain) GKSession *session;
@property (nonatomic, retain) NSMutableArray *peerList;
@property (nonatomic, retain) NSMutableArray *excludeList;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, assign) GKSessionMode sessionMode;

- (id) initWithDelegate:(id)aDelegate;
- (void) startSession;
- (void) stopSession;

@end

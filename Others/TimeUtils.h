//
//  TimeUtils.h
//
//

#import <UIKit/UIKit.h>
#import "DebugUtils.h"
#import <sys/time.h>

@interface Stopwatch : NSObject {
    struct timeval tv1, tv2;
}

+ (Stopwatch*) stopwatch;
- (void) lap:(NSString*)message;

@end

#ifndef DISTRIBUTION
#  define INIT_STOPWATCH(s) Stopwatch *s = [Stopwatch stopwatch]
#  define LAP(s, msg) [s lap:msg]
#else
#  define INIT_STOPWATCH(s) ;
#  define LAP(s, msg) ;
#endif
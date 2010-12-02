//
//  MeetViewDataSource.m
//
//

#import "MeetViewDataSource.h"
#import "kaya_meetAppDelegate.h"
#import "DBConnection.h"
#import "BlueTooth.h"

@interface NSObject (MeetViewControllerDelegate)
- (void)meetsDidUpdate:(MeetViewDataSource*)sender count:(int)count insertAt:(int)position;
- (void)meetsDidFailToUpdate:(MeetViewDataSource*)sender position:(int)position;
@end

static NSString* addressString = @" " ;

@implementation MeetViewDataSource

- (id)initWithController:(UITableViewController*)aController
{
    [super init];
     controller = aController;
    [loadCell setType:MSG_TYPE_LOAD_FROM_DB];
    isRestored = ([self restoreMeets:KYMEET_TYPE_UPDATE all:false] < 20) ? true : false;
	if (isRestored == true) {
		[self restoreMeets:KYMEET_TYPE_SENT all:false] ;
	}
	meetClient = nil;
	location = nil;
	reverseGeocoder = nil;
	longitude=0.0, latitude=0.0;
	[self getLocation] ;
	isRestored=true;
    return self;
}

- (void)dealloc {
	[super dealloc];
	[location release];
	[reverseGeocoder release];
	[meetClient cancel];
	[meetClient release];
}

//  get meet cell

- (MeetViewCell *)getMeetCell:(UITableView*)tableView atIndex:(int)index
{
	KYMeet* meet = [self meetAtIndex:index];
    if (meet == nil) return nil;
    
    MeetViewCell* cell = (MeetViewCell*)[tableView dequeueReusableCellWithIdentifier:@"MeetCell"];
    if (!cell) {
        cell = [[[MeetViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MeetCell"] autorelease];
    }
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [self countMeets];
    return  isRestored ? count : count+1;
}

//
// UITableViewDelegate
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    KYMeet* sts = [self meetAtIndex:indexPath.row];
//    return sts ? sts.cellHeight : 50;
	return 60;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeetViewCell* cell = [self getMeetCell:tableView atIndex:indexPath.row];
    if (cell) {
	// set image label in cell
		KYMeet* sts = [self meetAtIndex:indexPath.row];
		cell.primaryLabel.text   = [NSString stringWithFormat:@"meet with %ld friends", 
									sts.userCount-1	];
		cell.secondaryLabel.text = [NSString stringWithFormat:@" %@", [sts timestamp]
									];
		NSString *picURL = sts.user.profileImageUrl ;
		if ((picURL != (NSString *) [NSNull null]) && (picURL.length !=0)) {
			NSData *imgData = [[NSData dataWithContentsOfURL:
							   [NSURL URLWithString:picURL]] retain];
			cell.meetImageView.image = [[UIImage alloc] initWithData:imgData];
		} else {
			cell.meetImageView.image = nil;
		}
        return cell; 
    }
    else {
        return loadCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KYMeet* sts = [self meetAtIndex:indexPath.row];
    
    if (sts) {
        // Display user view
        //
        //UserViewController* userView = [[[UserViewController alloc] initWithMessage:sts] autorelease];
        //[[controller navigationController] pushViewController:userView animated:TRUE];
    }      
    else {
        // Restore meets from DB
        //
        int count  = [self restoreMeets:KYMEET_TYPE_SENT   all:true];
		
		if ( count < 10 ) {
			count += [self restoreMeets:KYMEET_TYPE_UPDATE all:true];
		}
        isRestored = true;
        
        NSMutableArray *newPath = [[[NSMutableArray alloc] init] autorelease];
        
        [tableView beginUpdates];
        // Avoid to create too many table cell.
        if (count > 0) {
//          if (count > 20) count = 20;
            for (int i = 0; i < count; ++i) {
                [newPath addObject:[NSIndexPath indexPathForRow:i + indexPath.row inSection:0]];
            }        
            [tableView insertRowsAtIndexPaths:newPath withRowAnimation:UITableViewRowAnimationTop];
        }
        else {
            [newPath addObject:indexPath];
            [tableView deleteRowsAtIndexPaths:newPath withRowAnimation:UITableViewRowAnimationLeft];
        }
        [tableView endUpdates];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];   
}


// post/get meet methods 

- (void)addMeet:(BluetoothConnect*)bt
{
    if (meetClient) return;
	meetClient = [[KYMeetClient alloc] initWithTarget:self action:@selector(meetDidPost:obj:)];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
	
    // put parameters for POST

	// meet date
	static NSDateFormatter* dateFormatter = nil ;
	NSLocale *          enUSPOSIXLocale;
	if ( dateFormatter == nil ) {
		enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[dateFormatter setLocale:enUSPOSIXLocale];
	}
	time_t now;
    time(&now);
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:now];
	[param setObject:[dateFormatter stringFromDate:date] forKey:@"time"];
	// location 
	[param setObject:[NSString stringWithFormat:@"%lf",latitude]  forKey:@"lat" ];
	[param setObject:[NSString stringWithFormat:@"%lf",longitude] forKey:@"lng"];
	//[param setObject:placeString forKey:@"location"];

	// lerror
	[param setObject:[NSString stringWithFormat:@"%f", lerror] forKey:@"lerror"];
	
	// bt
	[param setObject:bt.session.peerID forKey:@"user_dev"];
	if ( [bt numberOfPeers] == 0 ) {
		[param setObject:bt.session.peerID forKey:@"devs"];
	}
	else {
		NSString* query = [bt.peerList componentsJoinedByString:@","];
		NSLog(@"user %@, meet %@", bt.session.peerID, query);
		[param setObject:query forKey:@"devs"];
	}
	
	// Description
	[param setObject:[NSString stringWithFormat:@" %@ ",addressString] forKey:@"description"];
	
	// record the post as sent
	// NEED keep the temporary meet here until post receieved
	// KYMeet* sts = [KYMeet meetWithJsonDictionary:param type:KYMEET_TYPE_TEMP] ;
	// [self appendMeet:sts];
				   
	// poset meet from server
    [meetClient postMeet:param];
}

- (void)getUserMeets
{
    if (meetClient) return;
	insertPosition = 0;
	meetClient = [[KYMeetClient alloc] initWithTarget:self action:@selector(meetsDidReceive:obj:)];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
	
	// put parameters for GET
	// [param setObject:[NSString stringWithFormat:@"%d", since_id] forKey:@"date"];
    // [param setObject:@"200" forKey:@"count"];
	
    uint32_t user_id = [[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId"] ;
	// get meets from server
    [meetClient getUserMeets:param withUserId:user_id];
}

- (void)meetDidPost:(KYMeetClient*)sender obj:(NSObject*)obj
{
	meetClient = nil;
    [loadCell.spinner stopAnimating];
    
    if (sender.hasError) {
        if ([controller respondsToSelector:@selector(meetsDidFailToUpdate:position:)]) {
            [controller meetsDidFailToUpdate:self position:insertPosition];
        }
        
        if (sender.statusCode == 401) { // authentication fail
            kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate openLoginView];
        }
        [sender alert];
    }
	NSDictionary *dic = (NSDictionary*)obj ;
    if ([dic isKindOfClass:[NSDictionary class]]) {
		// remove post array
		//[self removeLastMeet] ;
		//[DBConnection beginTransaction];
		// KYMeet* sts = [KYMeet meetWithJsonDictionary:dic type:KYMEET_TYPE_SENT];
		//[sts insertDB];
		//[self insertSentMeet:sts atIndex:insertPosition];
		//[DBConnection commitTransaction];
		kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
		[appDelegate alert:@"Meet Posted" message:[NSString stringWithFormat:@"meet at %@",addressString]]; 
		[self getUserMeets];
	}
    else {
		// didn't get meet back from response
		return;
    }
	//if ([controller respondsToSelector:@selector(meetsDidUpdate:count:insertAt:)]) {
    //    [controller meetsDidUpdate:self count:1 insertAt:insertPosition];
	//}
}

// receieve meets arrage by getUserMeets
//
- (void)meetsDidReceive:(KYMeetClient*)sender obj:(NSObject*)obj
{
	meetClient = nil;
    [loadCell.spinner stopAnimating];
    
    if (sender.hasError) {
        if ([controller respondsToSelector:@selector(meetsDidFailToUpdate:position:)]) {
            [controller meetsDidFailToUpdate:self position:insertPosition];
        }
        
        if (sender.statusCode == 401) { // authentication fail
            kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate openLoginView];
        }
        [sender alert];
    }
   
    if (obj == nil) {
		// didn't get any meet from server
        return;
    }
    
    if ( ! [obj isKindOfClass:[NSDictionary class]] ) {
		return ;
	}
	NSDictionary *dic = (NSDictionary*)obj ;
	if ( ! [dic isKindOfClass:[NSDictionary class]] ) {
		return ;
	}	
	NSDictionary *u   = (NSDictionary*)[dic objectForKey:@"user"] ;
	if ( ! [u  isKindOfClass:[NSDictionary class]] ) {
		return ;
	}
	NSArray *ary = [u objectForKey:@"meets"] ;
	if ( ! [ary  isKindOfClass:[NSArray class]] ) {
		return ;
	}
	
    int unread = 0;    
    //KYMeet* lastMeet = [self lastMeet];
	// refresh the entire datamodel
	// if ([self countMeets]) [self removeAllMeets];
    if ([ary count]) {
        [DBConnection beginTransaction];
        // Add meets 
        for (int i = [ary count] - 1; i >= 0; --i) {
            NSDictionary *dic = (NSDictionary*)[ary objectAtIndex:i];
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            sqlite_int64 meetId = [[dic objectForKey:@"id"] longLongValue];
            if (![KYMeet isExists:meetId ]) {
				// add meet from Server
                KYMeet* sts = [KYMeet meetWithJsonDictionary:dic type:KYMEET_TYPE_UPDATE];
                [sts insertDB];                
                [self insertMeet:sts atIndex:insertPosition];
                ++unread;
            }else if ( [self meetById:meetId] == nil ) {
				[self insertMeet:[KYMeet meetWithId:meetId] atIndex:insertPosition];
				++unread;
			}
        }
        [DBConnection commitTransaction];
    }
    if ([controller respondsToSelector:@selector(meetsDidUpdate:count:insertAt:)]) {
        [controller meetsDidUpdate:self count:unread insertAt:insertPosition];
	}
}

//
// LocationManager delegate
//
- (void) getLocation
{
	if ( location == nil ) {
		location = [[LocationManager alloc] initWithDelegate:self];
	}
	[location getCurrentLocation];
}

- (void)locationManagerDidUpdateLocation:(LocationManager*)manager location:(CLLocation*)alocation
{
	if (latitude==0.0 || longitude==0.0) {
		latitude  = alocation.coordinate.latitude;
		longitude = alocation.coordinate.longitude;
		lerror = [alocation horizontalAccuracy] ;
	}
}

- (void)locationManagerDidReceiveLocation:(LocationManager*)manager location:(CLLocation*)alocation
{
    latitude  = alocation.coordinate.latitude;
    longitude = alocation.coordinate.longitude;
	lerror = [alocation horizontalAccuracy] ;
	reverseGeocoder =
	[[MKReverseGeocoder alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude,longitude)];
    reverseGeocoder.delegate = self;
    [reverseGeocoder start];
}

- (void)locationManagerDidFail:(LocationManager*)manager
{
    NSLog(@"Can't get current location.");
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    addressString = [[NSString stringWithFormat:@"At: %@ %@ (%@)",placemark.thoroughfare, placemark.locality, placemark.postalCode] retain] ;
	NSLog(@"place %@",addressString);
	[reverseGeocoder release];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSLog(@"MKReverseGeocoder has failed. %@",error);
	addressString = @"At Location" ;
	[reverseGeocoder release];
}

@end

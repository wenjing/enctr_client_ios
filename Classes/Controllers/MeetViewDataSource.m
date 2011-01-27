//
//  MeetViewDataSource.m
//
//

#import "MeetViewDataSource.h"
#import "kaya_meetAppDelegate.h"
#import "DBConnection.h"
#import "BlueTooth.h"

#import "MeetDetailView.h"

#define KAYAMEET_MAX_GET	1
#define KAYAMEET_MAX_LOAD	2


@interface NSObject (MeetViewControllerDelegate)
- (void)meetsDidUpdate:(MeetViewDataSource*)sender count:(int)count insertAt:(int)position;
- (void)meetsDidFailToUpdate:(MeetViewDataSource*)sender position:(int)position;
@end


@implementation MeetViewDataSource


- (id)initWithController:(UITableViewController*)aController
{
    [super init];
     controller = aController;
    [loadCell setType:MSG_TYPE_LOAD_FROM_DB];
	from_index = 0 ;
    isRestored = ([self restoreMeets:KYMEET_TYPE_UPDATE all:false] < 21) ? false : true ;
	meetClient = nil;
	location = nil;
	reverseGeocoder = nil;
	longitude=0.0, latitude=0.0;
	[self getLocation] ;
	userConfirmString = nil;
	showType = MEET_SOLO;
	controller.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
	if( refreshHeaderView == nil ) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - controller.tableView.bounds.size.height, controller.view.frame.size.width+2.0f, controller.tableView.bounds.size.height)];
		view.delegate = self ;
		[controller.tableView addSubview:view];
		refreshHeaderView = view ;
		[view release];
	}
	reloading = NO ;
	[refreshHeaderView refreshLastUpdatedDate];
    return self;
}

- (void)dealloc {
	[location release];
	[meetClient cancel];
	[meetClient release];
	[userConfirmString release];
	refreshHeaderView = nil;
	[super dealloc];
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
    return  isRestored ? count : count+1; // add load more cell if is not restored
}

//
// UITableViewDelegate
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    KYMeet* sts = [self meetAtIndex:indexPath.row];
//    return sts ? sts.cellHeight : 50;
	return 50;
    
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {	
	if ((indexPath.row % 2) == 1) { 
		cell.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1];
		cell.textLabel.backgroundColor = [UIColor blackColor];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	} else {
		cell.backgroundColor = [UIColor whiteColor];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (isRestored == false && indexPath.row == [self countMeets] ) return loadCell ;
    MeetViewCell* cell = [self getMeetCell:tableView atIndex:indexPath.row];
    if (cell) {
	// set image label in cell
		KYMeet* sts = [self meetAtIndex:indexPath.row];

		cell.primaryLabel.text   = sts.description  ;
		cell.secondaryLabel.text = [NSString stringWithFormat:@" %@ %@", [sts timestamp], sts.source];
		
//		NSString *picURL = sts.user.profileImageUrl ;
		NSString *picURL = NULL;
//		NSString *picURL = @"http://www.gravatar.com/avatar/12468ce98b80c55ec202850ac4026d75?size=50";
		if ((picURL != (NSString *) [NSNull null]) && (picURL.length !=0)) {
			NSData *imgData = [[[NSData dataWithContentsOfURL:
							   [NSURL URLWithString:picURL]] autorelease] retain];
			UIImage *aImage = [[UIImage alloc] initWithData:imgData];
			CGSize itemSize  = CGSizeMake(45,50);
			UIGraphicsBeginImageContext(itemSize);
			CGRect imageRect = CGRectMake(0.0,0.0,itemSize.width, itemSize.height);
			[aImage drawInRect:imageRect];
			cell.meetImageView.image = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
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
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];   
    if (sts) {
        // Display Meet Detail View
        //
        MeetDetailView* meetDetailView = [[[MeetDetailView alloc] initWithMeet:sts] autorelease];
		meetDetailView.hidesBottomBarWhenPushed = YES;
        [[controller navigationController] pushViewController:meetDetailView animated:TRUE];
    }
	else { 
		// restore meet from DB
        //
		int preCount = [self.meets count];
        int count  = [self restoreMeets:KYMEET_TYPE_UPDATE all:false];
        
		NSMutableArray *newPath = [[[NSMutableArray alloc] init] autorelease];
        [tableView beginUpdates];
        // Avoid to create too many table cell.
        if (count > 0) {
			//if (count > 2) count = 2;
            for (int i = 0, idx = 0; i < count; ++i) {
				if ( [self matchMeet:[self.meets objectAtIndex: i+preCount]] ){
					[newPath addObject:[NSIndexPath indexPathForRow:idx + indexPath.row inSection:0]];
					idx++;
				}
            }        
            [tableView insertRowsAtIndexPaths:newPath withRowAnimation:UITableViewRowAnimationRight];
        }
        else {
			isRestored = true;
            [newPath addObject:indexPath];
            [tableView deleteRowsAtIndexPaths:newPath withRowAnimation:UITableViewRowAnimationLeft];
        }
        [tableView endUpdates];
	}
}

- (void)addMeet:(BluetoothConnect*)bt
{
    if (meetClient) return;
	meetClient = [[KYMeetClient alloc] initWithTarget:self action:@selector(meetDidPost:obj:)];
    
	if (userConfirmString != nil)    [userConfirmString release] ;
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
	//[param setObject:bt.session.peerID forKey:@"user_dev"];
	latestUserCount = [bt numberOfPeers] + 1 ;
	[param setObject:[bt.session displayNameForPeer:bt.session.peerID] forKey:@"user_dev"];
	if ( [bt numberOfPeers] == 0 ) {
//		[param setObject:bt.session.peerID forKey:@"devs"];
		[param setObject:[bt.session displayNameForPeer:bt.session.peerID] forKey:@"devs"];
	}
	else {
		userConfirmString = [self getUserNameList:bt.peerList];
		NSString* query = [bt.peerList componentsJoinedByString:@","];
		NSLog(@"user %@, meet %@", [bt.session displayNameForPeer:bt.session.peerID], query);
		[param setObject:query forKey:@"devs"];
	}
	
	// Description
	// [param setObject:[NSString stringWithFormat:@" %@ ",addressString] forKey:@"description"];
	
	// record the post as sent
	// NEED keep the temporary meet here until post receieved
	// KYMeet* sts = [KYMeet meetWithJsonDictionary:param type:KYMEET_TYPE_TEMP] ;
	// [self appendMeet:sts];

	// poset meet from server
    [meetClient postMeet:param];
}

- (void)clickedAccept 
{
	NSLog(@"collision happen %d", latestPostId);
}


// GET latest meets from Server

- (void)getUserMeets
{
    if (meetClient) return;
	insertPosition = 0;
	meetClient = [[KYMeetClient alloc] initWithTarget:self action:@selector(meetsDidReceive:obj:)];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
	
	// last get meet date
	if( [meets count] ) {
		KYMeet *lastMeet = [self meetAtIndex:0] ;
		[param setObject:[self dateString:lastMeet.updateAt] forKey:@"after_updated_at"];
	}
	
	// put parameters for GET
	[param setObject:[NSString stringWithFormat:@"%d", KAYAMEET_MAX_GET] forKey:@"max_count" ];
    // [param setObject:[NSString stringWithFormat:@"%d", from_index]       forKey:@"from_index"];
	
    uint32_t user_id = [[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId"] ;
	// get meets from server
    [meetClient getUserMeets:param withUserId:user_id];
}

- (void)cancelConnect 
{
	if (meetClient != nil ) {
		[meetClient cancel];
		[meetClient release];
		meetClient = nil;
		[refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:controller.tableView];
		reloading = NO;
	}
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
	if ([dic isKindOfClass:[NSDictionary class]])
		 dic = [dic objectForKey:@"mpost"] ;
    if ([dic isKindOfClass:[NSDictionary class]]) {
		// remove post array
		//[self removeLastMeet] ;
		//[DBConnection beginTransaction];
		// KYMeet* sts = [KYMeet meetWithJsonDictionary:dic type:KYMEET_TYPE_SENT];
		//[sts insertDB];
		//[self insertSentMeet:sts atIndex:insertPosition];
		//[DBConnection commitTransaction];
		latestPostId = [[dic objectForKey:@"id"] longLongValue] ;
		
		kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
		if ( latestUserCount > 1 ) {
			[appDelegate dialog:@"Meet Confirm" message:[NSString stringWithFormat:@"met with %@",userConfirmString] action:@selector(clickedAccept) dg:self ]; 
		}
		else 
		{
			[appDelegate dialog:@"Meet Posted"  message:[NSString stringWithFormat:@"please confirm"] action:@selector(clickedAccept) dg:self ] ; 
		}
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

// receieve meets array by getUserMeets
//
- (void)meetsDidReceive:(KYMeetClient*)sender obj:(NSObject*)obj
{
	meetClient = nil;
    [loadCell.spinner stopAnimating];
	
	[refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:controller.tableView];
	reloading = NO;
    
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
    
    if ( ! [obj isKindOfClass:[NSArray class]] ) {
		return ;
	}
	NSArray *ary = (NSArray *)obj;
	
    int unread = 0;    
    if ([ary count]) {
        [DBConnection beginTransaction];
        // Add meets 
        for (int i = [ary count] - 1; i >= 0; --i) {
            NSDictionary *dic = (NSDictionary*)[[ary objectAtIndex:i] objectForKey:@"meet"];
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            sqlite_int64 meetId = [[dic objectForKey:@"id"] longLongValue];
			// check if meet in DB
            if (![KYMeet isExists:meetId ]) {
				// add meet from Server
                KYMeet* mt = [KYMeet meetWithJsonDictionary:dic type:KYMEET_TYPE_UPDATE];
                [mt insertDB];              
                [self insertMeet:mt atIndex:insertPosition];
                if ( [self matchMeet:mt] ) ++unread;
			// check if meet on memory
            }else if ( [self meetById:meetId] == nil ) {
				KYMeet* mt = [KYMeet meetWithId:meetId];
				[mt updateWithJsonDictionary:dic] ;
				[mt insertDB];
				[self insertMeet:mt atIndex:insertPosition];
                if ( [self matchMeet:mt] ) ++unread;
			// server update
			}else {
				KYMeet* mt = [self meetById:meetId] ;
				[mt updateWithJsonDictionary:dic] ;
				[mt insertDB];
			}
        }
        [DBConnection commitTransaction];
    }
    if ([controller respondsToSelector:@selector(meetsDidUpdate:count:insertAt:)]) {
        [controller meetsDidUpdate:self count:unread insertAt:insertPosition];
	}
}


// UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


// EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	reloading = YES;
	[self getUserMeets];
	//[refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:controller.tableView];
	// reloading = NO;
	// [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
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
//	reverseGeocoder =
//	[[MKReverseGeocoder alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude,longitude)];
//    reverseGeocoder.delegate = self;
//    [reverseGeocoder start];
}

- (void)locationManagerDidFail:(LocationManager*)manager
{
    lerror = 10000 ;
	//NSLog(@"Can't get current location.");
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    //addressString = [NSString stringWithFormat:@"%@ %@ (%@)",placemark.thoroughfare, placemark.locality, placemark.postalCode];
	//NSLog(@"place %@",addressString);
	[reverseGeocoder release];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
   // NSLog(@"MKReverseGeocoder has failed. %@",error);
	//addressString = @"At Location" ;
	[reverseGeocoder release];
}				 


// utilities

-(NSString *)dateString:(time_t)at 
{
	static NSDateFormatter* dateFormatter = nil ;
	NSLocale *enUSPOSIXLocale;
	if ( dateFormatter == nil ) {
		enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[dateFormatter setLocale:enUSPOSIXLocale];
	}
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:at];
	return [dateFormatter stringFromDate:date]   ;
}

- (NSString *)getUserNameList:(NSMutableArray *)ar
{
	NSMutableArray* pairs = [NSMutableArray array];
	for (int i = 0 ; i < [ar count] ; i ++ ) {
		NSRange end = [[ar objectAtIndex:i] rangeOfString:@":"] ;
		[pairs addObject:[[ar objectAtIndex:i] substringToIndex:end.location]];
	}
	NSString *query = [[pairs componentsJoinedByString:@","] retain];
	return query ;
}

@end

//
//  MeetViewDataSource.m
//
//

#import "MeetViewDataSource.h"
#import "kaya_meetAppDelegate.h"
#import "DBConnection.h"
#import "BlueTooth.h"

#import "MeetDetailView.h"
#import "StringUtil.h"


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
    isRestored = ([self restoreMeets:KYMEET_TYPE_UPDATE all:false] <= KAYAMEET_MAX_LOAD) ? false : true ;
	meetClient = nil;

	userConfirmString = nil;
	showType = MEET_SOLO;
	controller.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
      if (meetClient) {
	[meetClient cancel];
	[meetClient release];
      }
      if (userConfirmString) {
	[userConfirmString release];
      }
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
		
		NSString *headmapurl = @"http://maps.google.com/maps/api/staticmap?zoom=11&size=100x100&maptype=roadmap&format=png32&markers=color:green|size:small";
		NSString *mapurl = [NSString stringWithFormat:@"%@|%lf,%lf&sensor=false",headmapurl,sts.latitude,sts.longitude];
		mapurl = [mapurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

		HJManagedImageV *mi ;
		mi = (HJManagedImageV*)[cell viewWithTag:999];
		[mi clear];
		[mi showLoadingWheel];
		mi.url = [NSURL URLWithString:mapurl];
        
		//[imgMan manage:mi];	
		kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
		[delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:mi waitUntilDone:YES];
    }
    else {
        return loadCell;
    }
	return cell ;
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
            [tableView insertRowsAtIndexPaths:newPath withRowAnimation:UITableViewRowAnimationBottom];
        }
        else {
			isRestored = true;
            [newPath addObject:indexPath];
            [tableView deleteRowsAtIndexPaths:newPath withRowAnimation:UITableViewRowAnimationNone];
        }
        [tableView endUpdates];
	}
}

- (void)addMeet:(NSMutableDictionary*)param
{
    if (meetClient) return;
	meetClient = [[KYMeetClient alloc] initWithTarget:self action:@selector(meetDidPost:obj:)];
    // NSMutableDictionary *param = [NSMutableDictionary dictionary];
	
	kaya_meetAppDelegate *del = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
	
	// meet date
	time_t now;
	time(&now);
	[param setObject:[NSString dateString:now] forKey:@"time"];
	
	// location 
	[param setObject:[NSString stringWithFormat:@"%lf",del.latitude]  forKey:@"lat" ];
	[param setObject:[NSString stringWithFormat:@"%lf",del.longitude] forKey:@"lng"];
	[param setObject:[NSString stringWithFormat:@"%f", del.lerror]    forKey:@"lerror"];
	
	// record the post as sent
	// NEED keep the temporary meet here until post receieved
	// KYMeet* sts = [KYMeet meetWithJsonDictionary:param type:KYMEET_TYPE_TEMP] ;
	// [self appendMeet:sts];

	// post meet from server
    [meetClient postMeet:param];
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
		[param setObject:[NSString dateString:lastMeet.updateAt] forKey:@"after_updated_at"];
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
		NSString *collision = [dic objectForKey:@"collision"] ;
		kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
		if ( collision != (NSString *)[NSNull null] && collision == @"1" )
			[appDelegate alert: @"Post Meet Collision !"   message:nil]; 
		else										  
			[appDelegate alert: @"Post Meet Success   !"   message:nil];
		//[self getUserMeets];
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

@end

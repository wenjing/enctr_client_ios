//
//  CirkleViewController.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/27/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirkleViewController.h"
#import "CirkleEntryCell.h"
#import "CirkleQuery.h"
#import "CirkleSummary.h"
#import "CirkleEntryView.h"
#import "CirkleDetailViewController.h"

@implementation CirkleViewController
@synthesize listCircles;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [listCircles removeAllObjects];
    [listCircles release];
    _refreshHeaderView=nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

-(void)restoreAndLoadCirkles:(BOOL)withUpdate
{
    CirkleQuery *query = [[CirkleQuery alloc] initWithTarget:self 
                                                      action:@selector(cirklesDidLoad:)
                                           releaseAtCallBack:true];
    
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    
    _reloading = YES;
    
    //this query may or may not be asynchronous, so always do reloading first
    [query query:options withUpdate:withUpdate];
    
    //the query object is released when call to cirklesDidLoad: returns
}

- (void)cirklesDidLoad:(CirkleQuery*)sender
{
    //NSLog(@"Load cirkle results");
    if ([sender hasError]) {
        
        NSLog(@"Network error while updating circle view");
        
    } else {
        
        if ([sender hasMore]) {
            NSLog(@"  has more");
        }
        
        NSArray *results = [sender getResults];
        //NSLog(@"%@", results);
        
        //if the result is not empty, then rebuild listCircles

        NSInteger count = [results count];
        
        if (count > 0) {
            [listCircles removeAllObjects];
        
            NSLog(@"start rebuilding %d circles\n", count);
        
            for (int i=0; i<count; i++) {

                NSDictionary *dic = [results objectAtIndex:i];
        
                CirkleSummary *circle = [[CirkleSummary alloc] initWithJsonDictionary:dic];
        
                [listCircles addObject:circle];
                //NSLog(@"adding %d-th circle to list\n", i);
            }
        
            //NSLog(@"%@", listCircles);
            [self.tableView reloadData];
        }
    }

    [sender clear];
    
    _reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // reload circles every time view is reloaded
    listCircles = [[NSMutableArray alloc] init];
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:
                                           CGRectMake(0.0f, 
                                                      0.0f - self.tableView.bounds.size.height, 
                                                      self.view.frame.size.width, 
                                                      self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
    
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    [self restoreAndLoadCirkles:false];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [listCircles removeAllObjects];
    self.listCircles = nil;
    _refreshHeaderView=nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.listCircles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CircleTableIdentifier = @"CircleTableIdentifier";
    static NSInteger i=0;
    
	NSUInteger row = [indexPath row];
	
	CirkleEntryCell	*cell = (CirkleEntryCell *)[tableView dequeueReusableCellWithIdentifier:CircleTableIdentifier];
	if (cell == nil) {
		cell = [[[CirkleEntryCell alloc] 
				 initWithStyle:UITableViewCellStyleDefault 
				 reuseIdentifier:CircleTableIdentifier] autorelease];
        NSLog(@"A new circle view cell %d allocated, row %d", ++i, row);
    }
    
    [cell setCircle:[listCircles objectAtIndex:row]];
    
    //refactor later
    CGSize sizeOfFrame = [cell getSize];
    
    cell.frame = CGRectMake(0.0, 0.0, 320.0, GENERIC_MARGIN*2+PIC_WIDTH+sizeOfFrame.height+GENERIC_MARGIN*2+LG_PIC_SIZE);

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
    
    CirkleSummary *circle = [listCircles objectAtIndex:row];
    
	CGRect drawRect = CGRectMake(GENERIC_MARGIN*2+PIC_WIDTH, 0.0, CONTENT_WIDTH, 9999.0);
	
	CGSize size = [circle.contentString sizeWithFont:[UIFont systemFontOfSize:12] 
                                   constrainedToSize:drawRect.size];
	
	//NSLog(@"Row %d content Text Size = %@", row, NSStringFromCGSize(size));
	if ([circle.imageUrl count] > 0) {//if we have photo - 
		return (GENERIC_MARGIN*2+PIC_WIDTH+size.height+GENERIC_MARGIN*2+LG_PIC_SIZE);
	}
    
	return (GENERIC_MARGIN*2+PIC_WIDTH+size.height+GENERIC_MARGIN);
    
}

#pragma mark -
#pragma mark Table Delegate Methods
/*
 - (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
 NSUInteger row = [indexPath row];
 return row;
 }
 */
/* an example of not allow selecting the first row
 - (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 NSUInteger row = [indexPath row];
 if (row == 0) {
 return nil;
 }
 return indexPath;
 }
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
    CirkleSummary *aCircle = [listCircles objectAtIndex:row];
    /*
	NSString *rowValue = aCircle.nameString;
	
	NSString *message = [[NSString alloc] initWithFormat:@"You selected %@", rowValue];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Row Selected!" 
													message:message 
												   delegate:nil 
										  cancelButtonTitle:@"Yes I did" 
										  otherButtonTitles:nil];
	[alert show];
	[message release];
	[alert release];
     */
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    CirkleDetailViewController *detailViewController = [[CirkleDetailViewController alloc] initWithNibName:@"CirkleDetailViewController" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    detailViewController.summary = aCircle;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	//[self reloadTableViewDataSource];
	//[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    [self restoreAndLoadCirkles:true];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


@end

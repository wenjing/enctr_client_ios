//
//  CirkleDetailViewController.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/30/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirkleDetailViewController.h"
#import "CirkleDetailCell.h"
#import "kaya_meetAppDelegate.h"
#import "MessageViewController.h"

@implementation CirkleDetailViewController
@synthesize listDetails;
@synthesize summary;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [listDetails removeAllObjects];
    [listDetails release];
    [summary release];
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

- (void)restoreAndLoadNews {
    NewsQuery *query = [[NewsQuery alloc] initWithTarget:self action:@selector(newsDidLoad:)
                                       releaseAtCallBack:true];
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [query query:options withUpdate:true];
}

- (void)newsDidLoad:(NewsQuery*)sender {
    NSLog(@"Load news results");
    if ([sender hasError]) {
        NSLog(@"  has error");
    } else {
        if ([sender hasMore]) {
            NSLog(@"  has more");
        }
        NSArray *results = [sender getResults];
        NSLog(@"%@", results);
        
        // build listDetails
        [listDetails removeAllObjects];
        NSInteger count = [results count];
        
        NSLog(@"start building %d circleDetails\n", count);
        
        for (int i=0; i<count; i++) {
            
            NSDictionary *dic = [results objectAtIndex:i];
            
            CirkleDetail *circleDetail = [[CirkleDetail alloc] initWithJsonDictionary:dic];
            
            [listDetails addObject:circleDetail];
            //NSLog(@"adding %d-th circleDetail to list\n", i);
            //if (i>100)
            //    break;
        }
        
        [self.tableView reloadData];
    }
    
    [sender clear];

}

- (IBAction)composeAction:(id)sender
{
	// the custom icon button was clicked, handle it here
    kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
	MessageViewController *mV = appDelegate.messageView ;
	
    if ([summary isACircle]) {
        [mV postToWithId:summary.cId];
    } else {
        [mV postToUserWithId:summary.cId];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // reload circles every time view is reloaded
    listDetails = [[NSMutableArray alloc] init];
    self.title = [[NSString alloc] initWithFormat:@"%@",summary.nameString];
    
    [self restoreAndLoadNews];
    
    // add compose button as the nav bar's custom right view
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                  target:self action:@selector(composeAction:)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //[self.tableView setAlwaysBounceVertical:YES];
    //self.tableView.pagingEnabled = YES;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [listDetails removeAllObjects];
    self.listDetails = nil;
    [summary release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.listDetails count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CircleDetailTableIdentifier = @"CircleDetailTableIdentifier";
    static NSInteger i=0;
    
	NSUInteger row = [indexPath row];
	
	CirkleDetailCell	*cell = (CirkleDetailCell *)[tableView dequeueReusableCellWithIdentifier:CircleDetailTableIdentifier];
	if (cell == nil) {
		cell = [[[CirkleDetailCell alloc] 
				 initWithStyle:UITableViewCellStyleDefault 
				 reuseIdentifier:CircleDetailTableIdentifier] autorelease];
        NSLog(@"A new circle detail view cell %d allocated, row %d", ++i, row);
    }
    
    [cell setCircleDetail:[listDetails objectAtIndex:row]];
    
    //refactor later
    NSInteger sizeOfFrame = [cell getSize];
    
    cell.frame = CGRectMake(0.0, 0.0, 320.0, sizeOfFrame);
    
	return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
    
    CirkleDetail *circleDetail = [listDetails objectAtIndex:row];
    
    // variable name text
    
    UIFont *mainFont = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
    CGSize size;
    NSInteger height=0;
    CGRect drawRect;
    NSString *varString;
    
    if (circleDetail.type == CD_TYPE_ENCOUNETR) {
        drawRect = CGRectMake(CD_NAME_TOP_X, 0, CD_CONTENT_WIDTH, 9999.0);
        varString = circleDetail.nameString;
    
        size = [varString sizeWithFont:mainFont 
                       constrainedToSize:drawRect.size];
        height = height+size.height;
    }
    
    //NSLog(@"cell variable Text Size = %@", NSStringFromCGSize(size));
    
    // variable comment text
    drawRect = CGRectMake(CD_NAME_TOP_X, 0, CD_CONTENT_WIDTH, 9999.0);
    varString = circleDetail.contentString;
    
    size = [varString sizeWithFont:mainFont 
                          constrainedToSize:drawRect.size];
    height = height+size.height;

    NSInteger rowsOfImages = 0;
    
    //number of image rows
    if (circleDetail.type == CD_TYPE_ENCOUNETR) {
        if ((circleDetail.imageUrl==nil)) {
            rowsOfImages = 0;
        } else {
            rowsOfImages = [circleDetail.imageUrl count];
            // the list is 1 map + user images for encounter
            if (circleDetail.type == CD_TYPE_ENCOUNETR) {
                rowsOfImages--;
            }
        
            if ((rowsOfImages>=1) &&(rowsOfImages<=4))
                rowsOfImages=1;
            else {
                rowsOfImages = 0;
                NSLog(@"Too many user images in encounter.");
            }
        }
    }
    
    NSInteger picSize = 0;
    if (circleDetail.type == CD_TYPE_ENCOUNETR) 
        picSize = CD_MAP_SIZE;
    else if (circleDetail.type == CD_TYPE_TOPIC) {
        if ([circleDetail.imageUrl count] >0)
            picSize = CD_PHOTO_SIZE;
    }
    
	return (GENERIC_MARGIN+PIC_HEIGHT+GENERIC_MARGIN+picSize+GENERIC_MARGIN+
            height+GENERIC_MARGIN+
            rowsOfImages*( LG_PIC_SIZE+GENERIC_MARGIN)+
            GENERIC_MARGIN);
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
	NSString *rowValue = [listDetails objectAtIndex:row];
	
	NSString *message = [[NSString alloc] initWithFormat:@"You selected %@", rowValue];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Row Selected!" 
													message:message 
												   delegate:nil 
										  cancelButtonTitle:@"Yes I did" 
										  otherButtonTitles:nil];
	[alert show];
	[message release];
	[alert release];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end

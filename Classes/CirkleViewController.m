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

@implementation CirkleViewController
@synthesize listCircles;
@synthesize circleTableView;

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
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)restoreAndLoadCirkles
{
    CirkleQuery *query = [[CirkleQuery alloc] initWithTarget:self 
                                                      action:@selector(cirklesDidLoad:)
                                           releaseAtCallBack:true];
    
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [query query:options withUpdate:true];
    
    //the query object is released when call to cirklesDidLoad: returns
}

- (void)cirklesDidLoad:(CirkleQuery*)sender
{
    //NSLog(@"Load cirkle results");
    if ([sender hasError]) {
        NSLog(@"  has error");
    } else {
        if ([sender hasMore]) {
            //NSLog(@"  has more");
        }
        NSArray *results = [sender getResults];
        //NSLog(@"%@", results);
        
        // build listCircles
        [listCircles removeAllObjects];
        NSInteger count = [results count];
        
        //NSLog(@"start building %d circles\n", count);
        
        for (int i=0; i<count; i++) {

            NSDictionary *dic = [results objectAtIndex:i];
        
            CirkleSummary *circle = [[CirkleSummary alloc] initWithJsonDictionary:dic];
        
            [listCircles addObject:circle];
            //NSLog(@"adding %d-th circle to list\n", i);
        }
        //NSLog(@"%@", listCircles);
        [self.circleTableView reloadData];
        
    }
    [sender clear];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // reload circles every time view is reloaded
    listCircles = [[NSMutableArray alloc] init];
                   
    [self restoreAndLoadCirkles];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [listCircles removeAllObjects];
    self.listCircles = nil;
    
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
	static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
	NSUInteger row = [indexPath row];
	
	CirkleEntryCell	*cell = (CirkleEntryCell *)[tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
	if (cell == nil) {
		cell = [[[CirkleEntryCell alloc] 
				 initWithStyle:UITableViewCellStyleDefault 
				 reuseIdentifier:SimpleTableIdentifier] autorelease];
    }
    
    //cell.circle = [listCircles objectAtIndex:row];
    [cell setCircle:[listCircles objectAtIndex:row]];
    
    //refactor later
    CGSize sizeOfFrame = [cell getSize];
    
    cell.frame = CGRectMake(0.0, 0.0, 320.0, 57.0+sizeOfFrame.height+5+47+5);

	return cell;
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
	NSString *rowValue = [listCircles objectAtIndex:row];
	
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
}

//data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
    
    CirkleSummary *circle = [listCircles objectAtIndex:row];

	CGRect drawRect = CGRectMake(57, 0.0, 244, 9999.0);
	
	CGSize size = [circle.contentString sizeWithFont:[UIFont systemFontOfSize:12] 
                            constrainedToSize:drawRect.size];
	
	//NSLog(@"Row content Text Size = %@", NSStringFromCGSize(size));
	if (1) {//if we have photo - 
		return (57+size.height+5+54+5);
	}
	return (57+size.height+5);
    
}


@end

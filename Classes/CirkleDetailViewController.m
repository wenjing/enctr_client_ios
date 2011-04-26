//
//  CirkleDetailViewController.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/30/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirkleDetailViewController.h"
#import "CirkleDetailCell.h"
#import "CirkleMemberCell.h"
#import "kaya_meetAppDelegate.h"
#import "MessageViewController.h"
#import "UIImage+Resize.h"
#import <CoreText/CoreText.h>

#define CDV_SEGMENT_LIVE        0
#define CDV_SEGMENT_MEMBERS     1
#define CDV_SEGMENT_PLACES      2
#define CDV_SEGMENT_MORE        3

@implementation CirkleDetailViewController
@synthesize listDetails;
@synthesize listMembers;
@synthesize summary;
@synthesize query;
@synthesize upperController;
@synthesize segmentedControl;
@synthesize detailTable;
@synthesize nameCell;
@synthesize imageCell;
@synthesize placesView;

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/
- (void)dealloc
{
    [listDetails removeAllObjects];
    [listDetails release];
    [listMembers removeAllObjects];
    [listMembers release];
    [summary release];
    //first cancel, then release
    if (query) {
        [query clear];
    }
    [query release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(IBAction) segmentedControlIndexChanged{
    //NSLog(@"segmentedControlIndexChanged to %d", self.segmentedControl.selectedSegmentIndex);
    
    self.navigationItem.rightBarButtonItem = nil;
    
	switch (self.segmentedControl.selectedSegmentIndex) {
		case CDV_SEGMENT_LIVE:
            if (placesView!=nil)
                [self.view bringSubviewToFront:detailTable];
            
			// live news
            [detailTable reloadData];
            
            // add compose button as the nav bar's custom right view
            UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                target:self 
                                          action:@selector(composeAction:)];
            
            self.navigationItem.rightBarButtonItem = addButton;
            [addButton release];
            
			break;
            
		case CDV_SEGMENT_MEMBERS:
            if (placesView!=nil)
                [self.view bringSubviewToFront:detailTable];
			// members
            [detailTable reloadData];
            
            // add member button as the nav bar's custom right view
            UIBarButtonItem *addmButton = [[UIBarButtonItem alloc] 
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                          target:self 
                                          action:@selector(addMemberAction:)];
            
            self.navigationItem.rightBarButtonItem = addmButton;
            [addmButton release];
            
			break;
            
        case CDV_SEGMENT_PLACES:
            
            // places view
            if (placesView == nil) {
                placesView = [[CirklePlaceView alloc] initWithFrame:detailTable.frame listOfPlaces:listDetails];
                
                [self.view addSubview:placesView];
            }
            [self.view bringSubviewToFront:placesView];
            [placesView viewWillAppear:NO];
            
            break;
            
        case CDV_SEGMENT_MORE:
            if (placesView!=nil)
                [self.view bringSubviewToFront:detailTable];
            //edit the group: name and image
            [detailTable reloadData];
            
            // add save button
            UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] 
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                           target:self 
                                           action:@selector(saveCircleInfoAction:)];
            
            self.navigationItem.rightBarButtonItem = saveButton;
            self.navigationItem.rightBarButtonItem.enabled = false;
            [saveButton release];
            
            break;
            
		default:
			break;
	}
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)restoreAndLoadNews:(BOOL)withUpdate {
        
    NSMutableDictionary *options;
    
    NSString *idString = [[NSString alloc] initWithFormat:@"%lld", summary.cId];
    
    //user or circle
    if (summary.type == CIRCLE_TYPE_CIRCLE) {
        options = [[NSMutableDictionary alloc] initWithObjectsAndKeys:idString, @"cirkle_id", nil];
    } else {
        options = [[NSMutableDictionary alloc] initWithObjectsAndKeys:idString, @"friend_id", nil];
    }
    
    //NSLog(@"cid %lld, option dictionary: %@", summary.cId, options);
    
    //we need to get around not to reuse the same query in short time frame
    //this is a band-aid, does not solve the problem in the worse case
    if (!withUpdate) {
        //first time
        NewsQuery *firstQuery = [[NewsQuery alloc] initWithTarget:self action:@selector(newsDidLoad:)
                                                releaseAtCallBack:true]; 
        //the above object will be released when callback returns
        //this may or may not be synchronous
        [firstQuery query:options withUpdate:withUpdate];
    } else {
        [query initWithTarget:self action:@selector(newsDidLoad:)
            releaseAtCallBack:false];

        //Warning: this callback SHOULD be asynchronous
        [query query:options withUpdate:withUpdate];
    }
    
    [idString release]; //should i? yes
    [options release]; //query need to retain it
}

- (void)newsDidLoad:(NewsQuery*)sender {
    
    //NSLog(@"Load news results");
    if ([sender hasError]) {
        NSLog(@"  has error");
    } else {
        if ([sender hasMore]) {
            //NSLog(@"  has more");
        }
        NSArray *results = [sender getResults];
        
        //NSLog(@"new circleDetail %@", results);
        
        // build listDetails and listMembers - it's all or nothing
        NSInteger count = [results count];
        if (count > 0) {
            [listDetails removeAllObjects];
            [listMembers removeAllObjects];
        
            //NSLog(@"start building %d circleDetails\n", count);
        
            for (int i=0; i<count; i++) {
            
                NSDictionary *dic = [results objectAtIndex:i];
            
                NSString *eventType = [dic objectForKey:@"type"];
                if ([eventType isEqualToString:@"users"]) {
                    //NSLog(@"Parsing membership list");
                    
                    //read membership
                    NSArray *users = (NSArray *)[dic objectForKey:@"users"];
                    if (![users isKindOfClass:[NSArray class]]) {
                        NSLog(@"Bad format from member users array");
                    }
                    
                    NSArray *aUserArray;
                    for (aUserArray in users) {
                        //now the user - retain it
                        [listMembers addObject: [[aUserArray objectAtIndex:0] retain]];
                    }
                    
                } else {

                CirkleDetail *circleDetail = [[CirkleDetail alloc] initWithJsonDictionary:dic];
            
                [listDetails addObject:circleDetail];
                }
            }
        
            [detailTable reloadData];
        }
    }
    
    [sender clear];
    
    //start a new one, MUST set with true, if this is first query
    if (sender != query) {
        [self restoreAndLoadNews:true];
    }
}

- (IBAction)composeAction:(id)sender
{
	// the custom icon button was clicked, handle it here
    kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
	MessageViewController *mV = appDelegate.messageView ;
	
    //set delegate
    mV.delegate = self;
    
    [mV showCamera:YES];
    
    if ([summary isACircle]) {
        [mV postToWithId:summary.cId];
    } else {
        [mV postToUserWithId:summary.cId];
    }
}

- (IBAction) addMemberAction:(id)sender
{
    // the custom icon button was clicked, handle it here
    kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
	MessageViewController *mV = appDelegate.messageView ;
	
    //set delegate
    mV.delegate = self;
    
    [mV showCamera:NO];
    
    User *myself = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
    
    if ([summary isACircle]) {
        [mV inviteToWithId:summary.cId andCircleName:summary.nameString andName:myself.name];
    } else {
        //not supported yet
    }
}

- (IBAction) saveCircleInfoAction:(id)sender
{
    //send to server
    NSLog(@"saveCircleInfoAction clicked");
    
    self.navigationItem.rightBarButtonItem.enabled = false;
    
    KYMeetClient *client = [[KYMeetClient alloc] initWithTarget:self action:@selector(saveCircleDidFinish:obj:)];
    
    [client editMeet:circleName.text forMeetId:summary.cId photoData:holdImage];
    
}

- (void)saveCircleDidFinish:(KYMeetClient*)sender obj:(NSObject*)obj
{
    NSLog(@"saveCircleDidFinish result");
    if ([sender hasError]) {
        NSLog(@" has error");
    } else {
        //NSLog(@"%@", obj);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Circle customization saved!" 
                                                        message:@"Refresh Circle View to Update" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

// delegate to messageViewController
- (void) messageViewControllerDidFinish {
    //NSLog(@"messageViewControllerDidFinish called");
    // update data after a new topic
    [self restoreAndLoadNews:true];
    
    // also update circle summary view
    //NSLog(@"Refreshing circle summary");
    
    [upperController restoreAndLoadCirkles:true];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // reload circles every time view is reloaded
    listDetails = [[NSMutableArray alloc] init];
    listMembers = [[NSMutableArray alloc] init];
    self.title = [[NSString alloc] initWithFormat:@"%@",summary.nameString];
    
    // alloc query object
    query = [NewsQuery alloc];
    
    //first get local db cache
    [self restoreAndLoadNews:false];
    
    // add compose button as the nav bar's custom right view
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                  target:self action:@selector(composeAction:)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
    
    // initialize segmentedControl to default segment
    segmentedControl.selectedSegmentIndex = CDV_SEGMENT_LIVE ;
    
    // init edit view cells
    circleImage.url = summary.avatarUrl;
    kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
    [delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:circleImage waitUntilDone:YES];
    //[delg.objMan manage:circleImage];
    
    circleName.text = summary.nameString;
    
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
    [listMembers removeAllObjects];
    self.listMembers = nil;
    [summary release];
    if (query) {
        [query clear];
    }
    [query release];
    query = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //NSLog(@"viewWillAppear circleDetail");
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
    
    [placesView viewDidDisappear:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if (segmentedControl.selectedSegmentIndex == CDV_SEGMENT_LIVE) {
        return [self.listDetails count];
    } else if (segmentedControl.selectedSegmentIndex == CDV_SEGMENT_MEMBERS) {
        return [self.listMembers count];
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CircleDetailTableIdentifier = @"CircleDetailTableIdentifier";
    static NSString *CircleMemberIdentifier = @"CircleMemberIdentifier";
    
    //static NSInteger i=0;
    
	NSUInteger row = [indexPath row];
	
    if (segmentedControl.selectedSegmentIndex == CDV_SEGMENT_LIVE) {

        CirkleDetailCell	*cell = (CirkleDetailCell *)[detailTable dequeueReusableCellWithIdentifier:CircleDetailTableIdentifier];
        if (cell == nil) {
            cell = [[[CirkleDetailCell alloc] 
				 initWithStyle:UITableViewCellStyleDefault 
				 reuseIdentifier:CircleDetailTableIdentifier] autorelease];
            //NSLog(@"A new circle detail view cell %d allocated, row %d", ++i, row);
        }
    
        [cell setCircleDetail:[listDetails objectAtIndex:row]];
    
        //refactor later
        NSInteger sizeOfFrame = [cell getSize];
    
        cell.frame = CGRectMake(0.0, 0.0, 320.0, sizeOfFrame);
        
        return cell;
    } else if (segmentedControl.selectedSegmentIndex == CDV_SEGMENT_MEMBERS) {
        //make member view cell
        CirkleMemberCell *cell = (CirkleMemberCell*)[detailTable dequeueReusableCellWithIdentifier:CircleMemberIdentifier];
        if (cell == nil) {
            cell = [[[CirkleMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CircleMemberIdentifier] autorelease];

            //NSLog(@"A new member view cell %d allocated, row %d", ++i, row);
        } else {
            //reuse
            [cell.userImageView clear];
        }
        
        User *user = [listMembers objectAtIndex:row];
        
        cell.primaryLabel.text = user.name;
        
        kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
        //[cell.userImageView clear];
        
        //NSLog(@"circle member user url: %@", user.profileImageUrl);
        
        [cell.userImageView showLoadingWheel];
        
        cell.userImageView.url = [NSURL URLWithString:[user.profileImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        [delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:cell.userImageView waitUntilDone:YES];
        
        return cell;
    } else {
        //edit name and image
        if (row == 0) {
            
            return nameCell;
        }
        else {
            
            return imageCell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
    
    if (segmentedControl.selectedSegmentIndex == CDV_SEGMENT_MEMBERS) {
        return 57;
    } else if (segmentedControl.selectedSegmentIndex == CDV_SEGMENT_MORE) {
        if (row ==0)
            return 57;
        else 
            return 57;
    }
    
    CirkleDetail *circleDetail = [listDetails objectAtIndex:row];
    
    // variable name text
    
    UIFont *mainFont = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
    CGSize size;
    NSInteger height=0;
    CGRect drawRect;
    NSString *varString;
    
    if (circleDetail.type == CD_TYPE_ENCOUNETR) {
        drawRect = CGRectMake(CD_NAME_TOP_X, 0, CD_CONTENT_WIDTH, 9999.0);
        varString = circleDetail.nameList;
    
        size = [varString sizeWithFont:mainFont 
                       constrainedToSize:drawRect.size];
        height = height+size.height;
    }
    
    //NSLog(@"cell variable Text Size = %@", NSStringFromCGSize(size));
    
    // variable comment text
    circleDetail.size = CTFramesetterSuggestFrameSizeWithConstraints([circleDetail getFramesetter], CFRangeMake(0, 0), NULL, CGSizeMake(CD_CONTENT_WIDTH, CGFLOAT_MAX), NULL);
    
    height = height+circleDetail.size.height;

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
            GENERIC_MARGIN+CD_COMBUT_HEIGHT+GENERIC_MARGIN);
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
    if (segmentedControl.selectedSegmentIndex == CDV_SEGMENT_MORE) {
        
        NSUInteger row = [indexPath row];
        if(row == 1) {
            UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:nil
                                     delegate:self
                            cancelButtonTitle:@"Cancel"
                       destructiveButtonTitle:nil
                            otherButtonTitles:nil];
    
            [as addButtonWithTitle:@"Take A Picture "];
            [as addButtonWithTitle:@"Choose A Photo "];
            [as showInView:self.navigationController.parentViewController.view];
            [as release];
        }
    }
    
    //NSUInteger row = [indexPath row];
    /*
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
	[detailTable deselectRowAtIndexPath:indexPath animated:YES];
     */
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma -
#pragma TextField Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //NSLog(@"Hitting done");
    
    //check semicolon
    NSRange range = [textField.text rangeOfString:@":"];
    NSRange rangeb = [textField.text rangeOfString:@";"];
    if (range.location != NSNotFound || rangeb.location != NSNotFound) {
        //pop an alert and refuse the return key
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Circle name can't contain colon \":\" or semicolon \";\"" 
                                                        message:@"Please correct" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return NO;
    }
    
    [textField resignFirstResponder];
    self.navigationItem.rightBarButtonItem.enabled = true;
    return YES;
}

#pragma -
#pragma ActionSheet and ImagePicker Methods
- (void) actionSheet:(UIActionSheet *)as clickedButtonAtIndex: (NSInteger)buttonIndex
{
    // photo pick

    if (buttonIndex == 0 ) 
        return ;
        
    if ( imgPicker==nil ) {
        imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.allowsEditing = YES;
        imgPicker.delegate = self;
    }
    if(buttonIndex == 1) {
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imgPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    [self presentModalViewController:imgPicker animated:YES];

    self.navigationItem.rightBarButtonItem.enabled = true;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissModalViewControllerAnimated:YES];
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    if (image!=nil) {
        holdImage = [[image resizedImage:CGSizeMake(245,245) interpolationQuality:kCGInterpolationHigh] retain];
        
        circlePickedImage.image = [holdImage thumbnailImage:47 
                                                  transparentBorder:0 
                                                       cornerRadius:0 
                                               interpolationQuality:kCGInterpolationHigh];
        
        self.navigationItem.rightBarButtonItem.enabled = true;
    }
    // else no change
}

@end

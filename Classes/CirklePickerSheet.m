//
//  CirklePickerSheet.m
//  Cirkle
//
//  Created by Wenjing Chu on 4/18/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirklePickerSheet.h"
#import "QuartzCore/QuartzCore.h"
#import "CirkleSummary.h"
#import "CirkleMemberCell.h"
#import "kaya_meetAppDelegate.h"

@implementation CirklePickerSheet
@synthesize selections;
@synthesize tableView;

- (id)initWithFrame:(CGRect)frame owner:(id)anOwner action:(SEL)anAction
{
    owner = anOwner;
    action = anAction;
    
    //place above status bar
    frame.origin.y = 0.0f - frame.size.height;
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setAlpha:0.9];
        [self setBackgroundColor:[self sysBlueColor:0.7f]];
        
        // Add button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [button setFrame:CGRectMake(60.0f, 318.0f, 200.0f, 32.0f)];
        
        [button setBackgroundImage:[[UIImage imageNamed:@"whiteButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
        
        [button setTitle:@"OK" forState: UIControlStateHighlighted];
        [button setTitle:@"OK" forState: UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        
        [button addTarget:self action:@selector(removeView)
                        forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        
        // Add title
        title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 8.0f, 320.0f, 32.0f)];
        title.text = @"Select a Circle to Host";
        title.textAlignment = UITextAlignmentCenter;
        //title.lineBreakMode = UILineBreakModeWordWrap;
        title.textColor = [UIColor whiteColor];
        title.backgroundColor = [UIColor clearColor];
        title.font = [UIFont boldSystemFontOfSize:14.0f];
        [self addSubview:title];
        [title release]; 
        
        // Add border for the table
        CGRect bounds = CGRectMake(10.0f, 40.0f, 300.0f, 310.0f - 48.0f);
        UIView *borderView = [[UIView alloc] initWithFrame:bounds];
        [borderView setBackgroundColor:[self sysBlueColor:0.5f]];
        borderView.layer.cornerRadius = 5;
        
        [self addSubview:borderView];
        [borderView release];
        
        // Add table
        tableView = [[UITableView alloc] initWithFrame:CGRectInset(bounds, 4.0f, 4.0f)
                                                 style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.layer.cornerRadius = 5;
        
        [tableView reloadData];
        [self addSubview:tableView];
        [tableView release];
        
    }
    return self;
}

- (void) removeView
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];
    
    // Scroll away the overlay
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    CGRect rect = [self frame];
    rect.origin.y = 0.0f - rect.size.height;
    [self setFrame:rect];
    // Complete the animation
    [UIView commitAnimations];
    
    if ([owner respondsToSelector:action]) {
        if (selectedRow>=0)
        [owner performSelector:action withObject:[selections objectAtIndex:selectedRow]];
    }
}

- (void) presentView
{
    selectedRow = -1;
    // Scroll in the overlay
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    CGRect rect = [self frame];
    rect.origin.y = 0.0f; 
    
    [self setFrame:rect];
    // Complete the animation
    [UIView commitAnimations];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [title release];
    [tableView release];
    selections=nil;
    [super dealloc];
}

// Create a color of blue that mimics the official gray highlighting
- (UIColor *) sysBlueColor:(float) percent {
    float red = percent * 255.0f;
    float green = (red + 20.0f) / 255.0f;
    float blue = (red + 45.0f) / 255.0f;
    if (green > 1.0) green = 1.0f;
    if (blue > 1.0f) blue = 1.0f;
    return [UIColor colorWithRed:percent green:green blue:blue alpha:1.0f];
}

#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [selections count];
    //NSLog(@"selects count %d", [selections count]);
}

- (UITableViewCell *)tableView:(UITableView *)tView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CirkleMemberCell *cell = (CirkleMemberCell *)[tView dequeueReusableCellWithIdentifier:@"CirklePickerCell"];
    
    if (cell == nil) {
        cell = [[[CirkleMemberCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"CirklePickerCell"] autorelease];
    } else {
        //reuse
        [cell.userImageView clear];
    }
    
    // Set up the cell
    CirkleSummary *circle = (CirkleSummary *)[self.selections objectAtIndex:[indexPath row]];
    
    if(circle!=nil) {
        cell.primaryLabel.text = circle.nameString;
    
        kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
                
        [cell.userImageView showLoadingWheel];
        
        cell.userImageView.url = circle.avatarUrl;
        
        [delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:cell.userImageView waitUntilDone:YES];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57;
}

#pragma mark UITableViewDelegate Methods
// Respond to user selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{
    selectedRow = [newIndexPath row];
}

@end

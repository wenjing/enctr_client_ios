//
//  CirkleDetailView.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/30/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirkleDetailView.h"
#import "kaya_meetAppDelegate.h"
#import "CirkleDetailViewController.h"

@implementation CirkleDetailView

@synthesize userImage;
@synthesize circleDetail;
@synthesize images;
@synthesize size_names;
@synthesize size_comments;
@synthesize rowsOfImages;
@synthesize commentButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // 
        CGRect contentRect = self.bounds;
        CGFloat boundsX = contentRect.origin.x;
        
        CGRect drawRect = CGRectMake(boundsX+GENERIC_MARGIN, GENERIC_MARGIN, PIC_WIDTH, PIC_WIDTH);
        
        userImage = [[HJManagedImageV alloc] initWithFrame:drawRect];
        
        [self addSubview:userImage];
        
        images = [[NSMutableArray alloc] init];
        //prepare for up to 4 images
        [images addObject:[[HJManagedImageV alloc] init]];
        [images addObject:[[HJManagedImageV alloc] init]];
        [images addObject:[[HJManagedImageV alloc] init]];
        [images addObject:[[HJManagedImageV alloc] init]];

    }
    return self;
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
    [images removeAllObjects];
    [images release];
    [userImage release];
    [circleDetail release];
    //don't release comment button here - autorelease
    [super dealloc];
}

- (void)setCircleDetail:(CirkleDetail *)aCircleDetail {
    
    circleDetail = aCircleDetail;
    
    if (circleDetail.type == CD_TYPE_ENCOUNETR ) {
        [self encounterDetailSet];
    } else if (circleDetail.type == CD_TYPE_TOPIC) {
        [self topicDetailSet];
    }
    
    // comment button
    if (commentButton == nil) {
        commentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect]; //auto-released
        commentButton.backgroundColor = [UIColor clearColor];
        commentButton.titleLabel.font = [UIFont systemFontOfSize:MIN_SECONDARY_FONT_SIZE];
    
        [commentButton setTitle:@"comment" forState:UIControlStateNormal];
    }
    
    [commentButton addTarget:self action:@selector(addComment:) forControlEvents:UIControlEventTouchUpInside];

    
    //fontSize = [translationButton.titleLabel.text sizeWithFont:translationButton.titleLabel.font];      
    CGRect buttonFrame = CGRectMake(CD_NAME_TOP_X, 
                                    [self getSize] - CD_COMBUT_HEIGHT - GENERIC_MARGIN, 
                                    CD_COMBUT_WIDTH,
                                    CD_COMBUT_HEIGHT);
    
    [commentButton setFrame:buttonFrame];

    [self addSubview:commentButton];
    //NSLog(@"add comment button to %@", circleDetail.nameString);
    
    [self setNeedsDisplay];
}

- (void) topicDetailSet {
    
    UIFont *mainFont = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
    CGRect drawRect;
    NSString *varString;
    
    // no name list to display
    size_names = CGSizeZero;
    
    // variable comment text
    if (circleDetail.contentString) {
        
        drawRect = CGRectMake(CD_NAME_TOP_X, 0, CD_CONTENT_WIDTH, 9999.0);
        varString = circleDetail.contentString;
        
        size_comments = [varString sizeWithFont:mainFont 
                              constrainedToSize:drawRect.size];
    } else
        size_comments = CGSizeZero;
    
    // no rows of images
    rowsOfImages = 0;
    
    //set the user image url
    kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
    User *user = circleDetail.user;
    
    // set user image 
    // always clear it
    [userImage clear];
    if (user!=nil) {
        userImage.url = [NSURL URLWithString:[user.profileImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        userImage.oid = [NSString stringWithFormat:@"user_%d",user.userId];
        [delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:userImage waitUntilDone:YES];
    }

    //set the photo image
    
    //clear old images
    NSEnumerator *image_enum = [images objectEnumerator];
    HJManagedImageV *img;
    
    while ((img = [image_enum nextObject])) {
        [img clear];
    }
    
    NSEnumerator *enumerator = [circleDetail.imageUrl objectEnumerator];
    
    NSString *imgurl = [enumerator nextObject];
    
    if (imgurl ) {
        
        CGRect contentRect = self.bounds;
        CGFloat boundsX = contentRect.origin.x;
        
        //draw photo
        drawRect = CGRectMake(boundsX+CD_MAP_TOP_X, CD_MAP_TOP_Y, CD_PHOTO_SIZE, CD_PHOTO_SIZE);
        image_enum = [images objectEnumerator];
        img = [image_enum nextObject];
        img.frame = drawRect;
    
        img.url = [NSURL URLWithString:imgurl];
        [delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:img waitUntilDone:YES];
        [self addSubview:img];
    }

    
}
- (void) encounterDetailSet {
    
    //NSLog(@"setCircleDetail name %@ addr %@", circleDetail.nameString, circleDetail.addrString);
    // variable name text
    UIFont *mainFont = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
    
    CGRect drawRect = CGRectMake(CD_NAME_TOP_X, 0, CD_CONTENT_WIDTH, 9999.0);
    NSString *varString = circleDetail.nameString;
    
    size_names = [varString sizeWithFont:mainFont 
                 constrainedToSize:drawRect.size];
    
    //NSLog(@"cell variable Text Size = %@", NSStringFromCGSize(size));
    
    // variable comment text
    if (circleDetail.contentString) {
        
        drawRect = CGRectMake(CD_NAME_TOP_X, 0, CD_CONTENT_WIDTH, 9999.0);
        varString = circleDetail.contentString;
    
        size_comments = [varString sizeWithFont:mainFont 
                                    constrainedToSize:drawRect.size];
    } else
        size_comments = CGSizeZero;
    
    //number of image rows
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
    
    // alway clear
    [userImage clear];
    
/* encounters do not have user image url for now    
    //set the user image url
    kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
    User *user = circleDetail.user;
    
    if (user!=nil) {
        [userImage clear];
        userImage.url = [NSURL URLWithString:[user.profileImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        userImage.oid = [NSString stringWithFormat:@"user_%d",user.userId];
        [delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:userImage waitUntilDone:YES];
    }
*/    
    //set the map image

    NSEnumerator *enumerator = [circleDetail.imageUrl objectEnumerator];
    NSEnumerator *image_enum = [images objectEnumerator];
    
    NSString *imgurl;
    CGRect contentRect = self.bounds;
    CGFloat boundsX = contentRect.origin.x;
    int i = 0;
    HJManagedImageV *img;
    kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
    
    //clear old images
    while ((img = [image_enum nextObject])) {
        [img clear];
    }
    
    // reset
    image_enum = [images objectEnumerator];
    
    // first one is map
    imgurl = [enumerator nextObject];
    drawRect = CGRectMake(boundsX+CD_MAP_TOP_X, CD_MAP_TOP_Y, CD_MAP_SIZE, CD_MAP_SIZE);
    img = [image_enum nextObject];
    img.frame = drawRect;
    
    img.url = [NSURL URLWithString:imgurl];
    [delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:img waitUntilDone:YES];
    [self addSubview:img];
    
    //NSLog(@"Map Url at view %@", img.url);
    
    // the rest are people images
    while ((imgurl = [enumerator nextObject])) {
        
        drawRect = CGRectMake(boundsX+NAME_TOP_X+i*(LG_PIC_SIZE+GENERIC_MARGIN), 
                              CD_MAP_TOP_Y+CD_MAP_SIZE+GENERIC_MARGIN+size_names.height+GENERIC_MARGIN, 
                              LG_PIC_SIZE, 
                              LG_PIC_SIZE);
        img = [image_enum nextObject];
        img.frame = drawRect;
        
        img.url = [NSURL URLWithString:imgurl];
        [delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:img waitUntilDone:YES];
        //[delg.objMan manage:img];
        [self addSubview:img];
        
        //NSLog(@"%@", img.url);
        
        i++;
        if(i>=4)
            break;
    }
    
    // that's it
    //NSLog(@"setCircleDetail name %@ addr %@",circleDetail.nameString, circleDetail.addrString);
}

- (NSInteger) getSize {
    int picSize=0;
    if (circleDetail.type == CD_TYPE_ENCOUNETR ) {
        picSize = CD_MAP_SIZE;
    } else if (circleDetail.type == CD_TYPE_TOPIC) {
        if ([circleDetail.imageUrl count] >0)
            picSize = CD_PHOTO_SIZE;
    }
    
    return (GENERIC_MARGIN+PIC_HEIGHT+GENERIC_MARGIN+picSize+GENERIC_MARGIN+
                size_names.height+GENERIC_MARGIN+
                rowsOfImages*( LG_PIC_SIZE+GENERIC_MARGIN)+
                size_comments.height+
                GENERIC_MARGIN+CD_COMBUT_HEIGHT+GENERIC_MARGIN);
    
}

- (NSString *)updateTimeString
{
    // Calculate distance time string
    //
    NSString *timeString;
    
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now, circleDetail.timeAt);
    
    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        timeString = [NSString stringWithFormat:@"%dsec", distance];
    }
    else if (distance < 60 * 60) {  
        distance = distance / 60;
        timeString = [NSString stringWithFormat:@"%dmin",distance];
    }  
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        timeString = [NSString stringWithFormat:@"%dhr",distance];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        timeString = [NSString stringWithFormat:@"%dday",distance];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        timeString = [NSString stringWithFormat:@"%dwk",distance];
    }
    else {
        //to-do: i have not enough space to display it - readjust cell view
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            
            NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"dMMM" options:0
                                                                      locale:[NSLocale currentLocale]];
            [dateFormatter setDateFormat:formatString];

        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:circleDetail.timeAt];        
        timeString = [dateFormatter stringFromDate:date];
    }
    
    //NSLog(@"timestring is %@", timeString);
    return timeString;
}

- (void)drawRect:(CGRect)rect {
    
    // Font for name
	UIFont *nameFont = [UIFont boldSystemFontOfSize:12];
	
	// Color and font for the main text items
	UIColor *mainTextColor = nil;
	UIFont *mainFont = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
	
	// Color and font for the secondary text items
	UIColor *secondaryTextColor = nil;
	//UIFont *secondaryFont = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];
	
	mainTextColor = [UIColor blackColor];
	secondaryTextColor = [UIColor darkGrayColor];
	self.backgroundColor = [UIColor whiteColor];
	
	CGRect contentRect = self.bounds;
	
	[[UIColor whiteColor] set];
	UIRectFill(contentRect);
    
    CGFloat boundsX = contentRect.origin.x;
    CGPoint point;
    
    // Set the color for the main text items.
    [mainTextColor set];
    
    //NSLog(@"name string %@", circleDetail.nameString);
    
    // Draw the logo
    // this is just for encounter
     point = CGPointMake(boundsX+GENERIC_MARGIN, GENERIC_MARGIN);
     UIImage *pic = [UIImage imageNamed:@"circle_logo.png"];
     [pic drawAtPoint:point];
    
    // Draw name
    point = CGPointMake(boundsX + NAME_TOP_X, GENERIC_MARGIN);
    [circleDetail.nameString drawAtPoint:point 
                          forWidth:NAME_TOP_WIDTH 
                          withFont:nameFont 
                       minFontSize:MIN_MAIN_FONT_SIZE
                    actualFontSize:NULL 
                     lineBreakMode:UILineBreakModeTailTruncation 
                baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    
    // Draw timestring
    UIImage *icon;// = [UIImage imageNamed:@"timeofupdate_icon.png"];
    //point = CGPointMake(boundsX+19.5, CD_NAME_TOP_Y+size_names.height+GENERIC_MARGIN);
    //[icon drawAtPoint:point];
    
    [secondaryTextColor set];
    NSString *timeString = [self updateTimeString];
    
    point = CGPointMake(boundsX + TIME_TOP_X, TIME_TOP_Y);
    [timeString drawAtPoint:point 
                   forWidth:TIME_WIDTH 
                   withFont:mainFont 
                minFontSize:MIN_SECONDARY_FONT_SIZE 
             actualFontSize:NULL 
              lineBreakMode:UILineBreakModeTailTruncation 
         baselineAdjustment:UIBaselineAdjustmentAlignBaselines];

    if (circleDetail.type == CD_TYPE_ENCOUNETR) {
        // Draw address string
        CGRect drawRect = CGRectMake(boundsX+CD_ADDR_TOP_X, CD_MAP_TOP_Y, CD_ADDR_WIDTH, CD_ADDR_HEIGHT);
    
        [circleDetail.addrString drawInRect:drawRect withFont:mainFont];
    
        // Draw name list string
        drawRect = CGRectMake(boundsX+CD_NAME_TOP_X, CD_NAME_TOP_Y, CD_CONTENT_WIDTH, size_names.height);
    
        [circleDetail.nameString drawInRect:drawRect withFont:mainFont];
    
        // Draw image icon
        if ((circleDetail.type == CD_TYPE_ENCOUNETR) && ([circleDetail.imageUrl count] > 1)) {
            icon = [UIImage imageNamed:@"group_people_icon.png"];
            point = CGPointMake(boundsX+19.5, CD_NAME_TOP_Y+size_names.height+GENERIC_MARGIN);
            [icon drawAtPoint:point];
        }
    }
    
    // Draw comments
    if (size_comments.height != 0) {
        NSInteger commentTopY = GENERIC_MARGIN + PIC_WIDTH + GENERIC_MARGIN + GENERIC_MARGIN;
        if (circleDetail.type == CD_TYPE_ENCOUNETR) {
            commentTopY += CD_MAP_SIZE;
        } else if (circleDetail.type == CD_TYPE_TOPIC) {
            if ([circleDetail.imageUrl count]>0)
                commentTopY += CD_PHOTO_SIZE;
        }
        commentTopY += size_names.height+GENERIC_MARGIN+ rowsOfImages*(LG_PIC_SIZE+GENERIC_MARGIN);
        
        icon = [UIImage imageNamed:@"chatter_icon.png"];
        point = CGPointMake(boundsX+19.5, commentTopY);
        [icon drawAtPoint:point];
        
        CGRect drawRect = CGRectMake(boundsX+CD_NAME_TOP_X, 
                          commentTopY,
                          CD_CONTENT_WIDTH,
                          size_comments.height);
        [circleDetail.contentString drawInRect:drawRect withFont:mainFont];
    }
    
    //that's it
}


- (void) messageViewControllerDidFinish {
    //NSLog(@"circleDetailView got callback");
    //update data
    
    UITableView *tv = (UITableView *) self.superview.superview.superview;
    CirkleDetailViewController *vc = (CirkleDetailViewController *) tv.dataSource;
    //NSLog(@"refreshing circleDetail");
    
    [vc restoreAndLoadNews:true];
    
}

- (void) addComment:(UIButton *)sender {
    //need to know which topic's button is pressed
    kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
	MessageViewController *mV = appDelegate.messageView ;
    
    mV.delegate = self;
    
    if (self.circleDetail.type == CD_TYPE_TOPIC ) {
        [mV replyTo:self.circleDetail.cId];
    } else if (self.circleDetail.type == CD_TYPE_ENCOUNETR) {
        [mV postToWithId:self.circleDetail.cId];
    }
    
}

@end

//
//  MessageView.m

#import "MessageView.h"

#define kDeleteAnimationKey @"deleteAnimation"
#define kUndoAnimationKey   @"undoAnimation"

#define DELETE_BUTTON_INDEX 0

@implementation MessageView

@synthesize InReplyToChatId, InReplyToUserId, InReplyToMeetId, isReplyFlag, isInviteFlag, isUserFlag;

- (void)awakeFromNib
{
    recipient.font = [UIFont systemFontOfSize:16];
    charCount.font = [UIFont boldSystemFontOfSize:16];
    text.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"kayameet"];

    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"InReplyToChatId"];
    if (InReplyToChatId) {
        to.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"Reply-To"];
        recipient.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"recipient"];
    }
    InReplyToChatId = [number longValue]-1;

    number = [[NSUserDefaults standardUserDefaults] objectForKey:@"InReplyToUserId"];
    InReplyToUserId = [number longLongValue];

    number = [[NSUserDefaults standardUserDefaults] objectForKey:@"InReplyToMeetId"];
    InReplyToMeetId = [number longLongValue];
}

- (void)editReply:(sqlite_uint64)chatId
{
    InReplyToChatId   = chatId;
    InReplyToUserId   = 0;
    InReplyToMeetId   = 0;
    isReplyFlag = true;
    isInviteFlag = false;
    to.text = @"In-Reply-To:";
    recipient.text = [NSString stringWithFormat:@"char %d",chatId] ;
    recipient.enabled = true;
    recipient.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
}

- (void)editMessageUser:(User*)user
{
	InReplyToChatId = 0;
	InReplyToUserId = user.userId;
	InReplyToMeetId = 0;
	isReplyFlag = false  ;
	isInviteFlag = false ;
    isUserFlag = true;
	to.text = @"Post-To:";
	recipient.enabled = false;
}

//editMessageUser only requires an sqlite_int64, this version dis-entangles the KYMeet struct dependency
//make sure these two methods are identical
- (void)editMessageUserWithId:(sqlite_uint64)id
{
	InReplyToChatId = 0;
	InReplyToUserId = id;
	InReplyToMeetId = 0;
	isReplyFlag = false  ;
	isInviteFlag = false ;
    isUserFlag = true;
	to.text = @"Post-To:";
	recipient.enabled = false;
}

- (void)editMessage:(KYMeet*)mt
{
	InReplyToMeetId = mt.meetId ;
	isReplyFlag = false  ;
	isInviteFlag = false ;
	to.text = @"Post-To:";
	recipient.enabled = false;
}

//editMessage only requires an sqlite_int64, this version dis-entangles the KYMeet struct dependency
//make sure these two methods are identical

- (void)editMessageWithId:(sqlite_uint64)id
{
    InReplyToMeetId = id ;
	isReplyFlag = false  ;
	isInviteFlag = false ;
	to.text = @"Post-To:";
	recipient.enabled = false;
}

- (void)editInvite:(KYMeet*)mt
{
    InReplyToMeetId   = mt.meetId;
    InReplyToUserId   = 0;
    InReplyToChatId   = 0;
    isReplyFlag = false;
    isInviteFlag = true;
    to.text = @"To :";
    recipient.enabled = true;
    recipient.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
}

- (void)createTransform:(BOOL)isDelete
{
    if (isDelete) {
        CGAffineTransform transform = CGAffineTransformMakeScale(0.01, 0.01);
        CGAffineTransform transform2 = CGAffineTransformMakeTranslation(-80.0, 140.0);
        CGAffineTransform transform3 = CGAffineTransformMakeRotation (0.5);
        
        transform = CGAffineTransformConcat(transform,transform2);
        transform = CGAffineTransformConcat(transform,transform3);
        self.transform = transform;
    }
    else {
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.0);
        CGAffineTransform transform2 = CGAffineTransformMakeTranslation(0, 0);
        CGAffineTransform transform3 = CGAffineTransformMakeRotation (0);
        
        transform = CGAffineTransformConcat(transform,transform2);
        transform = CGAffineTransformConcat(transform,transform3);
        self.transform = transform;
    }
}

- (IBAction) clear:(id) sender
{
    [UIView beginAnimations:kDeleteAnimationKey context:self]; 

    UIBarButtonItem *item = (UIBarButtonItem*)sender;
    item.enabled = false;
    
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [self createTransform:true];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];
    
}

- (IBAction) undo:(id) sender
{
    text.text = undoBuffer;
    InReplyToMeetId = savedId;
    [undoBuffer release];
    undoBuffer = nil;
    [self createTransform:true];
    [self setNeedsDisplay];
    
    UIBarButtonItem *item = (UIBarButtonItem*)sender;
    item.enabled = false;
    
    [UIView beginAnimations:kUndoAnimationKey context:self]; 
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [self createTransform:false];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];
    
}

- (void)replaceButton:(UIBarButtonItem*)item index:(int)index
{
    NSMutableArray *items = [toolbar.items mutableCopy];
    [items replaceObjectAtIndex:index withObject:item];
    [toolbar setItems:items animated:false];
    [items release];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID isEqualToString:kDeleteAnimationKey]) {
        [self createTransform:false];
        
        undoBuffer = [text.text retain];
        savedId = InReplyToMeetId;
        InReplyToMeetId = 0;
        text.text = @"";
        charCount.textColor = [UIColor whiteColor];
        sendButton.enabled = false;
        [self setNeedsDisplay];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Undo" style:UIBarButtonItemStyleBordered target:self action:@selector(undo:)];
        [self replaceButton:item index:DELETE_BUTTON_INDEX];
    }
    else if ([animationID isEqualToString:kUndoAnimationKey]) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clear:)];
        item.style = UIBarButtonItemStyleBordered;
        [self replaceButton:item index:DELETE_BUTTON_INDEX];
    }
}

- (void)setCharCount
{
    int length = [text.text length];
    if (isInviteFlag) return ;
    if (undoBuffer && length > 0) {
        [undoBuffer release];
        undoBuffer = nil;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clear:)];
        item.style = UIBarButtonItemStyleBordered;
        [self replaceButton:item index:DELETE_BUTTON_INDEX];
    }
    
    length = 140 - length;
    if (length == 140) {
        sendButton.enabled = false;
    }
    else if (length < 0) {
        sendButton.enabled = false;
        charCount.textColor = [UIColor redColor];
    }
    else {
        sendButton.enabled = true;
        charCount.textColor = [UIColor whiteColor];
    }
    
    charCount.text = [NSString stringWithFormat:@"%d", length];
}

- (void)saveMessage
{
    [[NSUserDefaults standardUserDefaults] setObject:text.text forKey:@"kayameet"];
    [[NSUserDefaults standardUserDefaults] setObject:to.text forKey:@"to"];
    [[NSUserDefaults standardUserDefaults] setObject:recipient.text forKey:@"recipient"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:InReplyToMeetId] forKey:@"inReplyToMeetId"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLong:InReplyToChatId+1] forKey:@"inReplyToChatId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (isReplyFlag) {
        to.hidden = false;
        to.frame = CGRectMake(9, 0, 50, 43);
        
        recipient.frame = CGRectMake(50, 0, 200, 44);
        recipient.hidden = false;
        recipient.enabled = false;
        recipient.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        text.frame = CGRectMake(5, 44, 310, 112);
		address.hidden = true ;
		charCount.hidden = false;
    }else if (isInviteFlag) {
        to.hidden = false;
        to.frame = CGRectMake(9, 0, 50, 43);
        
        recipient.frame = CGRectMake(50, 0, 220, 44);
        recipient.hidden = false;
        recipient.enabled = true;
        recipient.textColor = [UIColor colorWithRed:0.3 green:0.4 blue:0.5 alpha:1.0];
        text.frame = CGRectMake(5, 44, 310, 112);
		address.hidden = false ;		
		charCount.hidden = true ;
    }else {
        to.hidden = true;
        recipient.hidden = true;
		address.hidden = true ;
		charCount.hidden = false;
        text.frame = CGRectMake(5, 5, 310, 156);
    }

}

- (void)drawRect:(CGRect)rect 
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (isReplyFlag) {
        CGContextSetLineWidth(context, 1);
        CGContextSetAllowsAntialiasing(context, false);
        CGContextSetRGBStrokeColor(context, 0.666, 0.666, 0.666, 1.0);
        CGPoint points[2] = {
            {0, 44}, {320, 44}
        };
        CGContextStrokeLineSegments(context, points, 2);
    }
}

- (void)dealloc {
    [super dealloc];
}


@end

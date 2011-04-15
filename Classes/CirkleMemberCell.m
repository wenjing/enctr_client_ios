//
//  CirkleMemberCell.m
//  Cirkle
//
//  Created by Wenjing Chu on 4/13/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirkleMemberCell.h"


@implementation CirkleMemberCell
@synthesize userImageView;
@synthesize primaryLabel;
@synthesize secondaryLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        CGRect contentRect = self.contentView.bounds;
        CGFloat boundsX = contentRect.origin.x;
        
        CGRect frame;

        frame= CGRectMake(boundsX+5+47+5+5 ,0, 200, 35);
        primaryLabel = [[UILabel alloc] initWithFrame:frame];
        primaryLabel.textAlignment = UITextAlignmentLeft;
        primaryLabel.font = [UIFont boldSystemFontOfSize:16];
        primaryLabel.backgroundColor = [UIColor clearColor];
        
        frame= CGRectMake(boundsX+5+47+5+5 ,35, 200, 22);
        secondaryLabel = [[UILabel alloc] initWithFrame:frame];
        secondaryLabel.textAlignment = UITextAlignmentLeft;
        secondaryLabel.font = [UIFont systemFontOfSize:12];
        secondaryLabel.backgroundColor = [UIColor clearColor];
        
        frame= CGRectMake(boundsX+5 ,5, 47, 47);
        userImageView = [[HJManagedImageV alloc] initWithFrame:frame];
        [self.contentView addSubview:primaryLabel];
        [self.contentView addSubview:secondaryLabel];
        [self.contentView addSubview:userImageView];
        
        //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		[primaryLabel release];
		[secondaryLabel release];
		[userImageView release];

    }
        
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [super dealloc];
}
@end

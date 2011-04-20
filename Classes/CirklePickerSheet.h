//
//  CirklePickerSheet.h
//  Cirkle
//
//  Created by Wenjing Chu on 4/18/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CirklePickerSheet : UIView <UITableViewDataSource, UITableViewDelegate> {
    UILabel *title;
    UITableView *tableView;
    NSInteger selectedRow;
    NSMutableArray *selections;
    id owner;
    SEL action;
}
@property (nonatomic, retain) NSMutableArray *selections;
@property (nonatomic, assign) UITableView *tableView;
- (UIColor *) sysBlueColor:(float) percent;
- (void) presentView;
- (id)initWithFrame:(CGRect)frame owner:(id)anOwner action:(SEL)anAction;

@end

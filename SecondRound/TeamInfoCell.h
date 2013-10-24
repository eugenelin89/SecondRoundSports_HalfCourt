//
//  TeamInfoCell.h
//  SecondRound
//
//  Created by Eugene Lin on 13-04-16.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>


#define TEAM_NAME_CELL @"Team Name"
#define TEAM_DETAIL_CELL @"Team Detail"
#define TEAM_NAME_TITLE_TEXT @"Team Name"
#define TEAM_DESC_TITLE_TEXT @"Details"

@protocol TeamInfoCellDelegate <NSObject>
-(void)nextButtonPressed;

@end


@interface TeamInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *teamInfoTextView;
@property (strong, nonatomic) NSString *cellType;
@property (weak, nonatomic) id<TeamInfoCellDelegate> delegate;

-(void) updateCell;
@end

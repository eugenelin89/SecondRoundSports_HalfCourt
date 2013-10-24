//
//  NewsFeedCell.h
//  SecondRound
//
//  Created by Eugene Lin on 13-08-13.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NewsFeedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *newsView;
@property (weak, nonatomic) IBOutlet UILabel *newsLabel;
@property (strong, nonatomic) PFObject *dataObj;
-(void)reloadCell;


@end

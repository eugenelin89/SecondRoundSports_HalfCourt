//
//  VenuPlayerCell.h
//  SecondRound
//
//  Created by Eugene Lin on 13-08-15.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenuPlayerCell : UITableViewCell
@property NSDictionary *playerDic;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) NSDictionary *playerProfile;

-(void)reloadCell;

@end

//
//  PlayerCell.h
//  SecondRound
//
//  Created by Eugene Lin on 13-06-13.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bkView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) NSDictionary *playerDic;
@property (weak, nonatomic) IBOutlet UILabel *rankingLabel;
-(void)reloadData;

@end

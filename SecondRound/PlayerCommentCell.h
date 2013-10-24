//
//  PlayerCommentCell.h
//  SecondRound
//
//  Created by Eugene Lin on 13-07-22.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface PlayerCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (strong, nonatomic) PFObject *playerObj;
-(void)reloadData;

@end

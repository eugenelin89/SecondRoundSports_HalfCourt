//
//  GameCell.h
//  SecondRound
//
//  Created by Eugene Lin on 13-07-26.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface GameCell : UITableViewCell
@property (strong, nonatomic) PFObject *gameObj;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *winLabel;

-(void)reloadData;

@end

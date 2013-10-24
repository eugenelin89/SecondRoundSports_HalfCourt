//
//  PlaceViewCell.h
//  SecondRound
//
//  Created by Eugene Lin on 13-06-07.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceViewCell : UITableViewCell
@property (strong, nonatomic, readonly) NSDictionary *venuInfo;
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *venueTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *venueNameLabel;
-(void)updateCellWithInfo:(NSDictionary *)info;
@end

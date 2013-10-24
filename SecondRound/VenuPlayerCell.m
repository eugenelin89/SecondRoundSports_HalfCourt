//
//  VenuPlayerCell.m
//  SecondRound
//
//  Created by Eugene Lin on 13-08-15.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "VenuPlayerCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation VenuPlayerCell
@synthesize playerDic = _playerDic;
@synthesize playerProfile = _playerProfile;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)reloadCell
{
    self.nameLabel.text = [self.playerProfile objectForKey:@"name"];
    self.messageLabel.text = [self.playerDic objectForKey:@"checkinMessage"];
    
    NSString *url = [self.playerProfile objectForKey:@"pic_square"];
    [self.imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"secondround_icon.png"]];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    //[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"ccc h:mma"];
    
    self.timeLabel.text = [dateFormatter stringFromDate:[self.playerDic objectForKey:@"checkInTime"]];
}

@end

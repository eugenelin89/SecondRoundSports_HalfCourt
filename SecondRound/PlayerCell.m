//
//  PlayerCell.m
//  SecondRound
//
//  Created by Eugene Lin on 13-06-13.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "PlayerCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppModel.h"

@implementation PlayerCell
@synthesize playerDic = _playerDic;

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

-(void)reloadData
{
    
    self.nameLabel.text = [self.playerDic valueForKey:@"name"];
    NSString *url = [self.playerDic objectForKey:@"pic_square"];
    [self.imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"secondround_icon.png"]];
    NSString *checkinMessage = [self.playerDic valueForKey:@"checkinMessage"];
    if([checkinMessage length] > 50)
        checkinMessage = [checkinMessage substringToIndex:49];
    if([checkinMessage length] > 0 )
        checkinMessage = [NSString stringWithFormat:@"\"%@\"", checkinMessage];
    self.messageLabel.text = checkinMessage;
    
    // display ranking
    NSString *fbId = [[self.playerDic objectForKey:@"id"] stringValue];
    NSNumber *rank = [((AppModel*)[AppModel sharedInstance]).rankingDic objectForKey:fbId];
    if(rank){
        self.rankingLabel.text = [rank stringValue];
    }else{
        self.rankingLabel.text = @"";
    }
    
    if([self.playerDic objectForKey:@"rateDic"]){
        
        // HIGHT LIGHT THE CELL HERE!
        NSLog(@"%@ is rated", self.nameLabel.text);
        self.bkView.backgroundColor = [UIColor lightGrayColor];
    }
    
    

}

@end

//
//  GameCell.m
//  SecondRound
//
//  Created by Eugene Lin on 13-07-26.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "GameCell.h"

@implementation GameCell
@synthesize gameObj = _gameObj;

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
    //self.textLabel.text = [self.gameObj objectForKey:@"gameId"];
    self.venueLabel.text = [self.gameObj objectForKey:@"venueName"];
    BOOL gameWon = [[self.gameObj objectForKey:@"gameWon"] boolValue];
    if(gameWon){
        self.winLabel.text = @"W";
    }else{
        self.winLabel.text = @"";
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    
    self.dateTimeLabel.text = [dateFormatter stringFromDate:self.gameObj.createdAt];
    
    
    
}

@end

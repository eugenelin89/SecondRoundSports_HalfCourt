//
//  NewsFeedCell.m
//  SecondRound
//
//  Created by Eugene Lin on 13-08-13.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "NewsFeedCell.h"

@implementation NewsFeedCell

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
    
    if([[self.dataObj objectForKey:@"priority"] intValue] == 1){
        self.newsView.backgroundColor = [UIColor redColor];
    }
    
    self.newsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.newsLabel.numberOfLines = 0;
    self.newsLabel.textColor = [UIColor whiteColor];
    
    NSString *newsContent = [self.dataObj objectForKey:@"newsfeed"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate *newsDate = self.dataObj.createdAt;
    NSString *dateString = [dateFormatter stringFromDate:newsDate];
    
    self.newsLabel.text = [NSString stringWithFormat:@"\"%@\" - %@", newsContent, dateString];
}

@end

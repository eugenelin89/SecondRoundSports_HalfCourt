//
//  PlayerCommentCell.m
//  SecondRound
//
//  Created by Eugene Lin on 13-07-22.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "PlayerCommentCell.h"
#import <SDWebImage/UIImageView+WebCache.h>


@implementation PlayerCommentCell

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
    self.nameLabel.text = [self.playerObj valueForKey:@"name"];
    NSString *url = [self.playerObj objectForKey:@"pic"];
    [self.imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"secondround_icon.png"]];
    NSString *commentMessage = [self.playerObj valueForKey:@"comment"];
    if([commentMessage length] > 39){
        commentMessage = [commentMessage substringToIndex:36];
        commentMessage = [NSString stringWithFormat:@"%@...", commentMessage];
    }
    if([commentMessage length] > 0 )
        commentMessage = [NSString stringWithFormat:@"\"%@\"", commentMessage];
    self.commentLabel.text = commentMessage;
    
}

@end

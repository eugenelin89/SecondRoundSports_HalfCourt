//
//  MemberCell.m
//  SecondRound
//
//  Created by Eugene Lin on 13-04-18.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "MemberCell.h"

@implementation MemberCell

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

@end

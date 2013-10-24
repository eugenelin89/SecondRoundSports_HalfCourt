//
//  LeftViewSelectionCell.m
//  Second Date
//
//  Created by Eugene Lin on 13-04-12.
//  Copyright (c) 2013 Second Date. All rights reserved.
//

#import "LeftViewSelectionCell.h"
#import <QuartzCore/QuartzCore.h>


@implementation LeftViewSelectionCell
@synthesize cellLabel = _cellLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray* nibArray = [[NSBundle mainBundle] loadNibNamed:@"LeftViewSelectionCell" owner:self options:nil];
        self = [nibArray objectAtIndex:0];
    }
    
    
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

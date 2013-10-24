//
//  PlaceViewCell.m
//  SecondRound
//
//  Created by Eugene Lin on 13-06-07.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "PlaceViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PlaceViewCell()
@end


@implementation PlaceViewCell
@synthesize venuInfo = _venuInfo;

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

-(void)updateCellWithInfo:(NSDictionary *)info
{
    _venuInfo = info;
    //self.textLabel.text = [self.venuInfo objectForKey:@"name"];
    self.venueNameLabel.text = [self.venuInfo objectForKey:@"name"];
    
    NSArray *categoryArray = [self.venuInfo objectForKey:@"categories"];
    if(categoryArray && [categoryArray isKindOfClass:[NSArray class]] && categoryArray.count >0){
        NSDictionary *catDic = [categoryArray objectAtIndex:0];
        if(catDic && [catDic isKindOfClass:[NSDictionary class]]){
            NSString *prefix = [[catDic objectForKey:@"icon"] objectForKey:@"prefix"];;
            NSString *suffix = [[catDic objectForKey:@"icon"] objectForKey:@"suffix"];
            if(prefix && [prefix characterAtIndex:prefix.length-1]=='_'){
                prefix = [prefix substringToIndex:prefix.length-1];
                NSString *url = [NSString stringWithFormat:@"%@%@", prefix,suffix];
                [self.venueTypeImage setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"secondround_icon.png"]];
                
                

            }
        
        }
    }
    

    
}

@end

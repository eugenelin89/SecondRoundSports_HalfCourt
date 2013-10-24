//
//  RatePlayerViewController.h
//  SecondRound
//
//  Created by Eugene Lin on 13-06-15.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseOfBaseViewController.h"

@protocol RatePlayerDelegate <NSObject>

-(void)cancelRatePlayer;
-(void)finishRatePlayer:(NSDictionary *)playerRating;


@end

@interface RatePlayerViewController : BaseOfBaseViewController
@property (weak, nonatomic) id<RatePlayerDelegate> delegate;
@property (strong, nonatomic) NSMutableDictionary *playerDic;

@end

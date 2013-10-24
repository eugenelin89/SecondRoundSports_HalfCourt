//
//  PlayerProfileViewController.h
//  SecondRound
//
//  Created by Eugene Lin on 13-06-26.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseOfBaseViewController.h"

@interface PlayerProfileViewController : BaseOfBaseViewController
@property (nonatomic, strong) NSDictionary *playerDic;
@property (nonatomic, strong) NSString* playerFbId; // if we do not of a dic, need this to query FB
@property (nonatomic, strong) NSString* status;

@end

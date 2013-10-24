//
//  PlayerCommentDetailViewController.h
//  SecondRound
//
//  Created by Eugene Lin on 13-07-24.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseOfBaseViewController.h"
#import <Parse/Parse.h>

@interface PlayerCommentDetailViewController : BaseOfBaseViewController
@property(strong, nonatomic) PFObject *commentRating;

@end

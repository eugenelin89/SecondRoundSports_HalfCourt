//
//  CheckedInViewController.h
//  SecondRound
//
//  Created by Eugene Lin on 13-06-09.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CheckedInViewControllerDelegate <NSObject>

-(void)userAcknowledgedCheckin;

@end

@interface CheckedInViewController : UIViewController
@property (weak, nonatomic) id<CheckedInViewControllerDelegate> delegate;
@end

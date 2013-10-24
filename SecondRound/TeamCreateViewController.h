//
//  TeamCreateViewController.h
//  SecondRound
//
//  Created by Eugene Lin on 13-04-16.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TeamCreateControllerDelegate <NSObject>

-(void) teamCreateCompleted;
-(void) teamCreateCancelled;

@end

@interface TeamCreateViewController : UIViewController
@property id<TeamCreateControllerDelegate> delegate;

@end

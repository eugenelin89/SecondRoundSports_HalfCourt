//
//  WinningViewController.h
//  SecondRound
//
//  Created by Eugene Lin on 13-06-19.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseOfBaseViewController.h"

@protocol WinningViewControllerDelegate <NSObject>

-(void)winningViewCancel;
-(void)winningVIewDone:(NSDictionary *)data;

@end

@interface WinningViewController : BaseOfBaseViewController
@property (weak, nonatomic) id<WinningViewControllerDelegate> delegate;

@end

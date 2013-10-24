//
//  BaseOfBaseViewController.h
//  SecondRound
//
//  Created by Eugene Lin on 13-06-17.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "ODRefreshControl.h"
@interface BaseOfBaseViewController : UIViewController<AppModeDelegate>
@property (strong, nonatomic) UIColor* defaultBackgroundColor;
@property (strong, nonatomic) UIColor* defaultSecondaryColor;
@property (strong, nonatomic) UIColor* defaultNavBarColor;
@property (nonatomic) BOOL runSpinner; // indicate whether we want out spinnier to be spinning when loading data
@property (strong, nonatomic) ODRefreshControl *refreshControl;

@end

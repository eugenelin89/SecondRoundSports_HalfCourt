//
//  BaseViewController.h
//  SecondRound
//
//  Created by Eugene Lin on 13-04-16.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftMenuViewController.h"
#import "BaseOfBaseViewController.h"



@interface BaseViewController : BaseOfBaseViewController <LeftMenuControllerDelegate>
@property (strong, nonatomic) UIColor* defaultBackgroundColor;
@property (strong, nonatomic) UIColor* defaultSecondaryColor;

@end

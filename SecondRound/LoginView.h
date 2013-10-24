//
//  LoginView.h
//  TosSocial
//
//  Created by Eugene Lin on 13-05-01.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIView
@property (weak, nonatomic) IBOutlet UIView *facebookLoginView;
@property (weak, nonatomic) IBOutlet UILabel *facebookLoginText;
@property (weak, nonatomic) IBOutlet UIView *privacyView;
@property (nonatomic) bool loginClicked;
@end

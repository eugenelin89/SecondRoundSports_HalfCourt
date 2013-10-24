//
//  BaseMemberViewController.h
//  SecondRound
//
//  Created by Eugene Lin on 13-05-06.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface BaseMemberViewController : BaseViewController



-(void)fbInfoReturned:(NSNotification*)notification;
-(void)loginViewRetracted; // to be overridden by subclass to inform that login view has retracted and we're officially logged in.
-(void)displayLogin;

@end

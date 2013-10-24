//
//  TeamSelectMemberViewController.h
//  SecondRound
//
//  Created by Eugene Lin on 13-04-18.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TeamSelectMemberControllerDelegate <NSObject>

-(void)selectMemberCancel;
-(void)selectMemberDone;

@end

@interface TeamSelectMemberViewController : UIViewController
@property (weak, nonatomic) id<TeamSelectMemberControllerDelegate> delegate;

@end

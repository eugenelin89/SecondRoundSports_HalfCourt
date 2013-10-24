//
//  BaseMemberViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-05-06.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "BaseMemberViewController.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LoginView.h"
#import "RestModel.h"
#import "AppModel.h"

#define DQ_MSG @"We have determined that the Facebook account you are using may not be your true identity.  If this were truly your active Facebook account, please ask an existing \"Second Round\" user to verify you by using the \"Refer a Friend\" function, or send email to info@secondroundsports.com.  We apologize for the inconvenience."

@interface BaseMemberViewController ()<AppModeDelegate>
@property (weak, nonatomic) LoginView *loginView;
@end

@implementation BaseMemberViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(fbInfoReturned:)
     name:FBInfoReturnedNotification
     object:nil];
    
    // Check the session for a cached token to show the proper authenticated
    // UI. However, since this is not user intitiated, do not show the login UX.
    // For some reason, the call to openSessionWithAllowLoginUI:NO if called
    // in viewDidAppear, it will first log out and then log in.  But called
    // in the viewDidLoad, if already logged in we will received sessionChanged.
    // If not logged in, we will receive nothing.  That's why we put it here
    // instead of viewDidAppear, so we won't log ourselves out.
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:NO]; // is this really required?
    
}

-(void)viewDidAppear:(BOOL)animated
{
    if (FBSession.activeSession.isOpen) {
        [[AppModel sharedInstance] activateOutstandingKiip];
    } else {
        // If not logged in, we need to segue to the logging in view.
        
        // DISPLAY LOGIN VIEW MODALLY.
        // #TODO: Refactor and exract the code
        [self displayLogin];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

bool _isWaitingForFb = NO;
bool _hasFbReturned = NO;
-(void)loggedIn // this may still be invoked when we're already logged but coming to the view for first time. 
{
    
    if(self.loginView) // We're just logging in.  If the loginView is nil then it means we're already logged in.
    {
        // If we're in here, it means we're just now logged in.  We need to perform the chain of actions that
        // follows after a user is confirmed logged in thru Facebook.
        // We may continue only if Facebook has returned our user info.
        _isWaitingForFb = YES;
        if(_hasFbReturned){
            _isWaitingForFb = NO;// resetting flags 
            _hasFbReturned = NO; // resetting flags
            // initiate login sequence step 1
            [self startLoginSequence];
        }else{
            _isWaitingForFb = YES;
        }
        
    }
    
}



#pragma mark - Chain of Logged In Actions
// 1. Checking if user already exist on our system
-(void)startLoginSequence
{
    // Ask AppModel if user already exists
    NSString* myFbId = [[((AppModel*)[AppModel sharedInstance]).myFbInfo objectForKey:@"id"] stringValue];
    [((AppModel*)[AppModel sharedInstance]) checkUserExists:myFbId fromSender:self];
}

-(void)userExists:(NSString *)userFbId
{
    NSLog(@"User exists!");
    // Go directly to step 3
    [self concludeLoginSequence];
}

-(void)userDoesNotExist:(NSString *)userFbId
{
    NSLog(@"User does not exists!");
    // Go to step 2
    [self checkCriteriaForUser:userFbId];
}

// 2. If user does not exist in your system, we need to check if he/she meets our criteria
-(void)checkCriteriaForUser:(NSString *)userFbId
{
    [((AppModel*)[AppModel sharedInstance]) checkUserQualification:userFbId fromSender:self];
}

-(void)userQualifies:(NSString *)userFbId
{
    // create user with approved = YES
    // save this approval status somewhere to save an extra network call
    [((AppModel*)[AppModel sharedInstance]) addUser:userFbId isApproved:YES byApprover:@"SYSTEM" fromSender:self];
}

-(void)userDoesNotQualify:(NSString *)userFbId
{
    // create user with approved = NO
    [((AppModel*)[AppModel sharedInstance]) addUser:userFbId isApproved:NO byApprover:@"NOT APPROVED" fromSender:self];
}

-(void)userAdded:(NSString *)userFbId
{
    // go to step 3
    [self concludeLoginSequence];
}

// 3. check if the user is approved.  This method can be called from
// By this step, doesn't matter what the previous action sequence was, the approval status
// should have been saved.  We should simply check the status and respond appropriately.
-(void)concludeLoginSequence
{
    if(((AppModel*)[AppModel sharedInstance]).userApproved){
        [self retractLoginView];
        [[AppModel sharedInstance] activateOutstandingKiip];

    }else{
        NSLog(@"Tell user he's not approved...");
        [self fbLogout];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Account"
                                                            message:DQ_MSG
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - Helper Mehtods
-(void)fbInfoReturned:(NSNotification*)notification
{
    NSLog(@"Facebook info returned: %@",((AppModel*)[AppModel sharedInstance]).myFbInfo);
    if(_isWaitingForFb){
        _hasFbReturned = NO; // resetting the flags.
        _isWaitingForFb = NO; // resetting the flags
        // initiate login sequence step 1
        [self startLoginSequence];
    }else{
        _hasFbReturned = YES;
    }
}


-(void)sessionStateChanged:(NSNotification*)notification
{
    if (FBSession.activeSession.isOpen) {
        [self loggedIn];
    } else {
        // DISPLAY LOGIN VIEW MODALLY.
        // Remove the displayLogin because it introduce a bug.
        // When we're already login but switch to another subclass of BaseMemberViewController,
        // the viewDidLoad calls openSessionWithAllowLoginUI:NO again as the new view is loaded.
        // what this ended up doing is having the session first close and then open.
        // but as the session is closed, it invokes sessionStateChanged and as a result displayLogin here
        // would be called.  Then as session opens, sessionStateChanged gets called again with session isOpen.
        // The result effect is the loging view drops down and then lifts up, which is very confusing.
        // What we need to do now is as user logs out, it will need to clear session, then actively calls
        // displayLogin.  In another word, displayLogin should only be called at viewDidAppear (for initial
        // launch of the view to display the login view) and when user proactively logging out.
        //[self displayLogin];
    }
}

-(void)retractLoginView
{
    [UIView animateWithDuration:1.0 delay:0 options:0 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y -= frame.size.height;
        [self.loginView setFrame: frame];
    } completion:^(BOOL finished) {
        [self.loginView removeFromSuperview];
        [self loginViewRetracted];
        [self.navigationController setNavigationBarHidden:NO animated:YES];

    }];
    

}

// this method is to be overriden by subclass
-(void)loginViewRetracted
{
    
}


-(void)displayLogin
{
        
    // create the LoginView, position it out of sight
    LoginView *loginView = [[LoginView alloc] init];
    self.loginView = loginView;
    [self.view addSubview:loginView];
    
    CGRect frame0 = self.view.frame;
    frame0.origin.y -= frame0.size.height;
    [loginView setFrame:frame0];
    
    // Dropdown fbLoginView
    [UIView animateWithDuration:1.0 delay:0 options:0 animations:^{
        //self.navigationController.navigationBarHidden = YES;
        CGRect frame = loginView.frame;
        frame.origin.y = 0;
        [loginView setFrame:frame];
        // Hide title bar
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        
    } completion:^(BOOL finished) {


    }];
    
    // slide it into sight and cover up the current view.
}

-(void)fbLogout
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate closeSession];
}



@end

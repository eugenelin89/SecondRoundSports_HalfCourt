//
//  LoginView.m
//  TosSocial
//
//  Created by Eugene Lin on 13-05-01.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "LoginView.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>



@implementation LoginView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray* nibArray = [[NSBundle mainBundle] loadNibNamed:@"LoginView" owner:self options:nil];
        self = [nibArray objectAtIndex:0];
        
        // Creating the login "button"
        // Facebook color: 59, 89, 152
        UIColor *fbBlue = [UIColor colorWithRed:(59/255.0) green:(89/255.0) blue:(182/255.0) alpha:1.0];
        self.facebookLoginView.backgroundColor = fbBlue;
        self.facebookLoginView.layer.cornerRadius = 5.f;
        UITapGestureRecognizer *fbViewRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fbViewTapped:)];
        [self.facebookLoginView addGestureRecognizer:fbViewRecognizer];
        self.loginClicked = NO;
        
        // Privacy View
        self.privacyView.layer.cornerRadius = 5.f;
        self.privacyView.backgroundColor = fbBlue;
        UITapGestureRecognizer *privacyRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(privacyViewTapped:)];
        [self.privacyView addGestureRecognizer:privacyRecognizer];
    }
    return self;
}

-(void)privacyViewTapped:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"privacy tapped");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PRIVACY_URL]];
}

-(void)fbViewTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if(!self.loginClicked){ // if we're not already in login process
        // login using FB.
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate openSessionWithAllowLoginUI:YES];
        self.facebookLoginText.textColor = [UIColor lightGrayColor];
        self.loginClicked = YES;
        
        // set a timer to re-enable login
        [NSTimer scheduledTimerWithTimeInterval:LOGIN_TIMEOUT
                                         target:self
                                       selector:@selector(resetLogin:)
                                       userInfo:nil
                                        repeats:NO];
    }else{
        NSLog(@"do nothing...");
    }
}

-(void)resetLogin:(NSTimer*)timer
{
    if(self.loginClicked){
        NSLog(@"reset Login");
        self.loginClicked = NO;
        self.facebookLoginText.textColor = [UIColor whiteColor];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (IBAction)facebookLoginButtonClicked:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:YES];
}

@end

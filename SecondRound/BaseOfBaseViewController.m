//
//  BaseOfBaseViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-06-17.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "BaseOfBaseViewController.h"
#import "AppDelegate.h"

@interface BaseOfBaseViewController ()
@property (strong, nonatomic) UIActivityIndicatorView* spinner;

@end

@implementation BaseOfBaseViewController

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
    self.defaultBackgroundColor = [UIColor colorWithRed:DEFAULT_RED green:DEFAULT_GREEN blue:DEFAULT_BLUE alpha:DEFAULT_ALPHA];
    self.defaultSecondaryColor = [UIColor colorWithRed:SECOND_RED green:SECOND_GREEN blue:SECOND_BLUE alpha:SECOND_ALPHA];
    self.defaultNavBarColor = [UIColor colorWithRed:SECOND_RED green:SECOND_GREEN blue:SECOND_BLUE alpha:0.1];
    
    
    self.view.backgroundColor = self.defaultBackgroundColor;
    self.navigationController.navigationBar.tintColor = self.defaultNavBarColor;
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = CGPointMake(160, 240);
    [self.view addSubview:self.spinner];
    self.runSpinner = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startSpinner
{
    if(self.runSpinner)
        [self.spinner startAnimating];
}

-(void)stopSpinner
{
    [self.spinner stopAnimating];
    //self.spinner.hidden = YES;
    //[self.spinner removeFromSuperview];
    //self.spinner = nil;
}

@end

//
//  CheckedInViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-06-09.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "CheckedInViewController.h"

@interface CheckedInViewController ()

@end

@implementation CheckedInViewController
@synthesize delegate = _delegate;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmedCheckin:(id)sender
{
    [self.delegate userAcknowledgedCheckin];
}

@end

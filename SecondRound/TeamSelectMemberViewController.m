//
//  TeamSelectMemberViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-04-18.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "TeamSelectMemberViewController.h"

@interface TeamSelectMemberViewController ()

@end

@implementation TeamSelectMemberViewController

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

- (IBAction)cancelButtonClicked:(id)sender
{
    [self.delegate selectMemberDone];
}

- (IBAction)doneButtonClicked:(id)sender
{
    [self.delegate selectMemberCancel];
}

@end

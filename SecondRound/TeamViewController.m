//
//  TeamViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-04-16.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "TeamViewController.h"
#import "IIViewDeckController.h"
#import "TeamCreateViewController.h"
#import "AFJSONRequestOperation.h"
#import "AppDelegate.h"

@interface TeamViewController ()<TeamCreateControllerDelegate>

@end

@implementation TeamViewController

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

#pragma mark - View Controller Delegate
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((TeamCreateViewController *)segue.destinationViewController).delegate = self;
}

#pragma mark - TeamCreateControllerDelegate Delegate Methods
-(void)teamCreateCancelled
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

-(void)teamCreateCompleted
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];    
}

#pragma mark - Actions
- (IBAction)menuButtonClicked:(id)sender
{
    [self.viewDeckController toggleLeftViewAnimated:YES];
}

- (IBAction)test:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://httpbin.org/ip"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"IP Address: %@", [JSON valueForKeyPath:@"origin"]);
    } failure:nil];
    
    [operation start];
}

- (IBAction)testLogout:(id)sender {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate closeSession]; // is this really required?

    
}


@end

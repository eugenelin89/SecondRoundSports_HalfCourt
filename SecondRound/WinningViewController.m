//
//  WinningViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-06-19.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "WinningViewController.h"
#import "AppModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>



@interface WinningViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) NSDictionary *myFbInfo;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation WinningViewController

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
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    //self.imageView.contentMode = UIViewContentModeScaleToFill;
    self.imageView.layer.borderWidth = 2.0;
    self.imageView.layer.cornerRadius = 5.0f;
    self.imageView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    
    
    self.myFbInfo = ((AppModel *)[AppModel sharedInstance]).myFbInfo;
    NSString *url = [self.myFbInfo objectForKey:@"pic"];

    [self.imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"secondround_icon.png"]];
    
    // colots
    self.navBar.tintColor = self.defaultNavBarColor;

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonClicked:(id)sender
{
    [self.delegate winningViewCancel];
}

@end

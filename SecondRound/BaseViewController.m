//
//  BaseViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-04-16.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "BaseViewController.h"
#import "MapViewController.h"
#import "TeamViewController.h"
#import "ViewController.h"
#import "LeftMenuViewController.h"
#import "IIViewDeckController.h"
#import "GameViewController.h"
#import "PlayersViewController.h"
#import "AppDelegate.h"

@interface BaseViewController ()
@end

@implementation BaseViewController

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
    //((LeftMenuViewController *)self.viewDeckController.leftController).delegate = self;
    ((LeftMenuViewController *)self.viewDeckController.leftController).delegate = self;
    
}

-(void)viewDidAppear:(BOOL)animated
{
   
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)switchToViewWithId:(NSString *)viewId
{
    if([viewId isEqualToString:MAP_VIEW_ID] && ![((UINavigationController *)self.viewDeckController.centerController).topViewController isKindOfClass:[MapViewController class]])
    {
        UINavigationController *mapViewController = (UINavigationController *) [self.storyboard instantiateViewControllerWithIdentifier:MAP_VIEW_ID ];
        self.viewDeckController.centerController = mapViewController;
        
    }else if([viewId isEqualToString:NEWS_FEED_VIEW_ID] && ![((UINavigationController *)self.viewDeckController.centerController).topViewController isKindOfClass:[ViewController class]])//note:ViewController is actually the view for News Feed
    {
        UINavigationController *newsFeedViewController = (UINavigationController *) [self.storyboard instantiateViewControllerWithIdentifier:NEWS_FEED_VIEW_ID ];
        self.viewDeckController.centerController = newsFeedViewController;
        
    }else if([viewId isEqualToString:GAME_VIEW_ID] && ![((UINavigationController *)self.viewDeckController.centerController).topViewController isKindOfClass:[GameViewController class]])
    {
        UINavigationController *gameViewController = (UINavigationController *) [self.storyboard instantiateViewControllerWithIdentifier:GAME_VIEW_ID ];
        self.viewDeckController.centerController = gameViewController;
        
    }else if([viewId isEqualToString:PLAYER_VIEW_ID] && ![((UINavigationController *)self.viewDeckController.centerController).topViewController isKindOfClass:[PlayersViewController class]])
    {
        UINavigationController *playersViewController = (UINavigationController *) [self.storyboard instantiateViewControllerWithIdentifier:PLAYER_VIEW_ID ];
        self.viewDeckController.centerController = playersViewController;
    }
}



@end

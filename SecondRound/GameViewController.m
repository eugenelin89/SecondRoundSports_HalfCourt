//
//  GameViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-06-08.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "GameViewController.h"
#import "IIViewDeckController.h"
#import "AppModel.h"
#import "GameCell.h"
#import "GameDetailViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface GameViewController ()<AppModeDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *gamesArray;
@property (nonatomic) int gameIndex;

@end

@implementation GameViewController
@synthesize gamesArray = _gamesArray;

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
    
    AppModel *appModel = [AppModel sharedInstance];
    if(appModel.myFbInfo){
        [appModel getGamesForUser:[[appModel.myFbInfo objectForKey:@"id"] stringValue] fromSender:self];
    }
    
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
}

-(void)dropViewDidBeginRefreshing:(ODRefreshControl*)refreshControl
{
    self.runSpinner = NO; // since ODRefreshControl has it's own spinner
    AppModel *appModel = [AppModel sharedInstance];
    if(appModel.myFbInfo){
        [appModel getGamesForUser:[[appModel.myFbInfo objectForKey:@"id"] stringValue] fromSender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[GameDetailViewController class]]){
        ((GameDetailViewController *)segue.destinationViewController).gamePlayersDic = [self.gamesArray objectAtIndex:self.gameIndex];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)menuItemClicked:(id)sender {
    [self.viewDeckController toggleLeftViewAnimated:YES];
}

-(IBAction)addGameButtonClicked:(id)sender
{
    [[AppModel sharedInstance] didUserCheckIn:self];
    
}

-(void)userCheckedIn:(NSDictionary *)checkinInfo
{
    NSLog(@"User did check in: %@", checkinInfo);
   [self performSegueWithIdentifier:@"ADD_GAME" sender:self]; 
}

-(void)userDidNotCheckIn
{
    NSLog(@"User has not checked in near this location in the last 3 hours.");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Checkin Required"
                                                        message:PLEASE_CHECKIN
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Check-in", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // cancel 0, check-in 1
    // if is 1 then need to segue to map
    if(buttonIndex == 1){
        ((AppModel*)[AppModel sharedInstance]).mapToCheckin = YES;
        [self switchToViewWithId:MAP_VIEW_ID];
    }
}

-(void)receivedGames:(NSArray *)games
{
    NSLog(@"My Games: %@", games);
    self.gamesArray = games; // array of PFObjects
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];

}

// base class listen to notification and once fb info returns this selector is invoked.
-(void)fbInfoReturned:(NSNotification*)notification{
    [super fbInfoReturned:notification];
    AppModel *appModel = [AppModel sharedInstance];
    [appModel getGamesForUser:[[appModel.myFbInfo objectForKey:@"id"] stringValue] fromSender:self];
}

#pragma mark - UITableView Delegate and Datasource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.gamesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameCell *cell;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"GAME_CELL"];
    if(!cell){
        cell = [[GameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GAME_CELL"];
    }
    if(self.gamesArray){
        cell.gameObj = [self.gamesArray objectAtIndex:indexPath.row];
        [cell reloadData];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.gameIndex = indexPath.row;
    [self performSegueWithIdentifier:@"VIEW_GAME_SEGUE" sender:self];
}

@end

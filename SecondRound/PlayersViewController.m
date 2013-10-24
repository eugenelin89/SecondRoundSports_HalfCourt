//
//  PlayersViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-06-25.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "PlayersViewController.h"
#import "IIViewDeckController.h"
#import "AppModel.h"
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import "PlayerCell.h"
#import "PlayerProfileViewController.h"


@interface PlayersViewController ()<UITableViewDelegate, UITableViewDataSource, AppModeDelegate, UISearchBarDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *playerSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *nearByPlayersArray;
@property (strong, nonatomic) NSMutableArray *allPlayersArray;
@property (strong, nonatomic) NSMutableArray *currentDisplayingArray;
@property (nonatomic) int selectedPlayerRow;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) NSMutableDictionary *nearbyPlayersDics;
@property (nonatomic) bool isShowingAll;

@end

@implementation PlayersViewController
@synthesize nearByPlayersArray = _nearByPlayersArray;
@synthesize allPlayersArray = _allPlayersArray;

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
    [self getAllPlayers];
	// Do any additional setup after loading the view.
    self.playerSearchBar.tintColor = self.defaultSecondaryColor;
    self.playerSearchBar.layer.cornerRadius = 5.f;
    self.tableView.layer.cornerRadius = 5.f;
    
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];

}

-(void)dropViewDidBeginRefreshing:(ODRefreshControl*)refreshControl
{
    self.runSpinner = NO; // since ODRefreshControl has it's own spinner
    
    if(self.isShowingAll){
        [self getAllPlayers];
    }else{
        [[AppModel sharedInstance] nearbyPlayers:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)menuButtonClicked:(id)sender
{
    [self.viewDeckController toggleLeftViewAnimated:YES];

}

- (IBAction)meButtonClicked:(id)sender
{
    [self performSegueWithIdentifier:@"PLAYER_PROFILE" sender:sender];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([sender isKindOfClass:[UIBarButtonItem class]]){
        // from me button
        ((PlayerProfileViewController *)segue.destinationViewController).playerDic = ((AppModel*)[AppModel sharedInstance]).myFbInfo;
    }else{
        ((PlayerProfileViewController *)segue.destinationViewController).playerDic = [self.currentDisplayingArray objectAtIndex:self.selectedPlayerRow];
    }
}

- (IBAction)segmentControlClicked:(id)sender
{
    if(self.segmentControl.selectedSegmentIndex == 0) // all
    {
        NSLog(@"ALL");
        self.isShowingAll = YES;
        if(self.allPlayersArray){
            // just reload with all players
            self.currentDisplayingArray = [self.allPlayersArray mutableCopy];
            [self.tableView reloadData];
        }else{
            // call out to the network for all players
            // Don't really need coz we have it already
        }
    }else{
        NSLog(@"NEARBY");
        self.isShowingAll = NO;
        if(self.nearByPlayersArray){
            // just reload with nearby players
            self.currentDisplayingArray = [self.nearByPlayersArray mutableCopy];
            [self.tableView reloadData];
        }else{
            // call out to the network
            [[AppModel sharedInstance] nearbyPlayers:self];
        }
    }
}

// Pre-Condition, players is an array of NSDictionary
// We should really get rid of this and just let AppModel chain it up
-(void)receivedNearbyPlayers:(NSArray *)players
{
    self.nearByPlayersArray = nil; // initialize the merged array to nil and we will give it a new one later.
    self.nearbyPlayersDics = [[NSMutableDictionary alloc] init];
    for(int i=0; i<players.count; i++){
        [self.nearbyPlayersDics setObject:[players objectAtIndex:i] forKey:[[players objectAtIndex:i] valueForKey:@"fbUserId"]];
    }
    [[AppModel sharedInstance] getFbProfilesForPlayers:players useKeyName:@"fbUserId" fromSender:self]; // fbUserId
}
// We should really get rid of this and just let AppModel chain it up
// received nearby players.  call back of the cally by above func receivedNearbyPlayers
-(void)receivedPlayerFbProfiles:(NSArray *)playerFbProfiles
{
    // merge checkin data with the data from Facebook
    for(int i=0; i<playerFbProfiles.count; i++){
        NSString *fbUserId = [[[playerFbProfiles objectAtIndex:i] valueForKey:@"id"] stringValue];
        NSMutableDictionary *aDic = [self.nearbyPlayersDics valueForKey:fbUserId];
        
        [[playerFbProfiles objectAtIndex:i] setObject:[aDic valueForKey:@"checkinLocation"] forKey:@"checkinLocation"];
        [[playerFbProfiles objectAtIndex:i] setObject:[aDic valueForKey:@"checkinMessage"] forKey:@"checkinMessage"];
        [[playerFbProfiles objectAtIndex:i] setObject:[aDic valueForKey:@"createdAt"] forKey:@"createdAt"];
        [[playerFbProfiles objectAtIndex:i] setObject:[aDic valueForKey:@"venueId"] forKey:@"venueId"];
        [[playerFbProfiles objectAtIndex:i] setObject:[aDic valueForKey:@"venueName"] forKey:@"venueName"];
    }
        
    self.nearByPlayersArray = [[playerFbProfiles sortedArrayUsingComparator:^NSComparisonResult(NSDictionary* player1, NSDictionary* player2) {
        return [self rankPlayer:player1 vsPlayer:player2];
    }] mutableCopy];
    
    
    self.nearbyPlayersDics = nil; // no longer need this dic.  reset it back to nil.
    if(self.segmentControl.selectedSegmentIndex == 1){
        self.currentDisplayingArray = [self.nearByPlayersArray mutableCopy];
        self.isShowingAll = NO;
    }
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

#pragma mark - UITablieView Delegate and DataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.currentDisplayingArray)
        return self.currentDisplayingArray.count;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerCell *cell;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"PLAYER_CELL"];
    if(!cell){
        cell = [[PlayerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PLAYER_CELL"];
    }
    if(self.currentDisplayingArray){
        cell.playerDic = [self.currentDisplayingArray objectAtIndex:indexPath.row];
        [cell reloadData];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPlayerRow = indexPath.row;
    [self performSegueWithIdentifier:@"PLAYER_PROFILE" sender:self];
}

#pragma mark - AppModelDelegate methods


-(NSComparisonResult) rankPlayer:(NSDictionary*)player1 vsPlayer:(NSDictionary*)player2
{
    NSString *fbId1 = [[player1 objectForKey:@"id"] stringValue];
    NSString *fbId2 = [[player2 objectForKey:@"id"] stringValue];
    NSNumber *ranking1 = [((AppModel *)[AppModel sharedInstance]).rankingDic objectForKey:fbId1];
    NSNumber *ranking2 = [((AppModel *)[AppModel sharedInstance]).rankingDic objectForKey:fbId2];
    NSComparisonResult result = (NSComparisonResult)NSOrderedSame;
    if(ranking1 && ranking2){ // both are ranked
        if([ranking1 intValue] > [ranking2 intValue])
            result = (NSComparisonResult)NSOrderedDescending;
        else
            result = (NSComparisonResult)NSOrderedAscending;
    }else if(ranking1){ // player2 unranked
        result = (NSComparisonResult)NSOrderedAscending;
    }else if(ranking2){ // player1 unranked
        result = (NSComparisonResult)NSOrderedDescending;
    }else{
        result = (NSComparisonResult)NSOrderedSame;
    }
    return result;
}


-(void)receivedAllPlayerFbProfiles:(NSArray *)players
{
    NSLog(@"All Players: %@", players);
    
    self.allPlayersArray = [[players sortedArrayUsingComparator:^NSComparisonResult(NSDictionary* player1, NSDictionary* player2) {
        return [self rankPlayer:player1 vsPlayer:player2];
    }] mutableCopy];
    
    if(self.segmentControl.selectedSegmentIndex == 0)
    {
        self.currentDisplayingArray = [self.allPlayersArray mutableCopy]; // do this if user selected ALL players
        self.isShowingAll = YES;
    }
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}



-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self.playerSearchBar resignFirstResponder];
}

#pragma mark - UISearchBar Delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSArray *tempArray;
    if(self.isShowingAll)
        tempArray = [[NSArray alloc] initWithArray:self.allPlayersArray];
    else
        tempArray = [[NSArray alloc] initWithArray:self.nearByPlayersArray];
    
    [self.currentDisplayingArray removeAllObjects];
    
    if(searchText.length == 0){
            [self.currentDisplayingArray addObjectsFromArray:tempArray];
    }else{
        for(NSDictionary *player in tempArray){
            NSString *friendName = [player objectForKey:@"name"];
            NSRange r = [friendName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(r.location != NSNotFound){
                [self.currentDisplayingArray addObject:player];
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Helper Methods
-(void)getAllPlayers
{
    if(FBSession.activeSession.isOpen){
        [[AppModel sharedInstance] allPlayers:self];
    }
}

-(void)loginViewRetracted // if we got here, we know we've just logged in.
{
    [self getAllPlayers];
}






@end

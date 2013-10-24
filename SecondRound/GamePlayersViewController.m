//
//  GamePlayersViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-06-10.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <Parse/Parse.h>
#import "GamePlayersViewController.h"
#import "AppModel.h"
#import "PlayerCell.h"
#import "RatePlayerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@interface GamePlayersViewController ()<AppModeDelegate, RatePlayerDelegate>
// When receiving an array of nearby players from Parse, store it is dictionary because we're still going out to
// Facebook to get the FB info of the players.  It's inefficient to merge two arrays, 
@property (strong, nonatomic) NSMutableDictionary *nearbyPlayersDics;
// The merged data from Facebook and Parse.
// Note, when a player is evaluated, there will be a pointer in the dic in the array
// that points to the evluated data.  this is to help update the uitable view as well as
// saving data if user deicdes to go back to re-evaluate the same player
@property (strong, nonatomic) NSMutableArray *nearByPlayersArray;
// Array of players that have been rated
@property (strong, nonatomic) NSMutableArray *evaluatedPlayersArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) int selectedPlayerRow;
@property (weak, nonatomic) IBOutlet UIView *tapView;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UILabel *yesNo;
@property (weak, nonatomic) IBOutlet UILabel *toggleLabel;

@property (nonatomic) BOOL isWon;

@property (nonatomic) BOOL gameSaved;

@end

@implementation GamePlayersViewController
@synthesize nearbyPlayersDics = _nearbyPlayersDics;
@synthesize nearByPlayersArray = _nearByPlayersArray;

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
    [[AppModel sharedInstance] nearbyPlayers:self];
    self.tableView.layer.cornerRadius = 5.f;
    self.tapView.layer.cornerRadius = 5.f;
    self.view2.backgroundColor = self.defaultBackgroundColor;
    self.tapView.backgroundColor = self.defaultSecondaryColor;
    
    
    UITapGestureRecognizer *tapViewRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(tapViewTapped:)];
    [self.tapView addGestureRecognizer:tapViewRecognizer];
    
    self.yesNo.hidden = YES;
    self.isWon = NO;

    
}



// user tapped "did you win" tap view.
-(void)tapViewTapped:(UIGestureRecognizer *)gestureRecognizer
{
    self.yesNo.hidden = NO;
    NSLog(@"tapped!");
    if([self.yesNo.text isEqualToString:@"YES"]){
        self.yesNo.text = @"NO";
        self.toggleLabel.text = @"Tap here if you did";
        self.isWon = NO;

    }else{
        self.yesNo.text = @"YES";
        self.toggleLabel.text = @"Tap here if you lost.  Be honest.";
        self.isWon = YES;

    }
}

// Pre-Condition, players is an array of NSDictionary
-(void)receivedNearbyPlayers:(NSArray *)players
{
    self.nearByPlayersArray = nil; // initialize the merged array to nil and we will give it a new one later.
    self.nearbyPlayersDics = [[NSMutableDictionary alloc] init];
    for(int i=0; i<players.count; i++){
        [self.nearbyPlayersDics setObject:[players objectAtIndex:i] forKey:[[players objectAtIndex:i] valueForKey:@"fbUserId"]];
    }
    [[AppModel sharedInstance] getFbProfilesForPlayers:players useKeyName:@"fbUserId" fromSender:self]; //fbUserId
}

// received Nearby players.
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
    self.nearByPlayersArray = (NSMutableArray*)playerFbProfiles;
    self.nearbyPlayersDics = nil; // no longer need this dic.  reset it back to nil.
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[RatePlayerViewController class]]){
        ((RatePlayerViewController *)segue.destinationViewController).playerDic = [self.nearByPlayersArray objectAtIndex:self.selectedPlayerRow];
        ((RatePlayerViewController *)segue.destinationViewController).delegate = self;
    }
    
}

#pragma mark - UITablieView delegate and datasource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.nearByPlayersArray)
        return self.nearByPlayersArray.count;
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
    if(self.nearByPlayersArray){
        cell.playerDic = [self.nearByPlayersArray objectAtIndex:indexPath.row];
        [cell reloadData];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPlayerRow = indexPath.row;
    
    NSDictionary *playerDic = [self.nearByPlayersArray objectAtIndex:self.selectedPlayerRow];
    NSNumber *playerId = [playerDic objectForKey:@"id"];
    AppModel *appModel = [AppModel sharedInstance];
    NSNumber *myId = [appModel.myFbInfo objectForKey:@"id"];
    if([playerId isEqualToNumber:myId]){
        
    }else{
        [self performSegueWithIdentifier:@"RATE_PLAYER" sender:self];
    }
}

#pragma mark - Rate Player Delegate
-(void)cancelRatePlayer
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

// delegate called from rate player view, indicate that a player has been rated.
-(void)finishRatePlayer:(NSDictionary *)playerRating
{
    if(!self.evaluatedPlayersArray)
        self.evaluatedPlayersArray = [[NSMutableArray alloc] init];
    
    // remove previouly added rating for this particular player
    NSString *userId = [[playerRating objectForKey:@"id"] stringValue];
    for(NSDictionary *dic in self.evaluatedPlayersArray){
        NSString *theId = [[dic objectForKey:@"id"] stringValue];
        if([theId isEqualToString:userId]){
            [self.evaluatedPlayersArray removeObject:dic];
            break;
        }
    }
    
    [self.evaluatedPlayersArray addObject:playerRating];
    [self dismissViewControllerAnimated:YES completion:^(void){}];
    [self.tableView reloadData];
}


- (IBAction)okButtonClicked:(id)sender
{
    // Because we will not wait for the first save to come back, we will need to create our own unique gameId.
    // Will create unique gameId by using playerId_venueId_dateString
    NSLog(@"OK Button Clicked.  %@", self.evaluatedPlayersArray);
    NSString *checkinId = [((AppModel*)[AppModel sharedInstance]).checkinInfo objectForKey:@"checkinId"];
    NSString *venueId = [((AppModel*)[AppModel sharedInstance]).checkinInfo objectForKey:@"venueId"];
    NSString *venueName = [((AppModel*)[AppModel sharedInstance]).checkinInfo objectForKey:@"venueName"];
    NSString *fbId = [[((AppModel *)[AppModel sharedInstance]).myFbInfo objectForKey:@"id"] stringValue];
    NSString* dateTimeStr = [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] stringValue];
    
    NSString* gameId = [NSString stringWithFormat:@"%@_%@",fbId,dateTimeStr];
    
    AppModel *appModel = [AppModel sharedInstance];
    
    // 1. save to Game table: gameId, checkinId, venueId, fbId
    [appModel saveGameWithId:gameId
                                   forCheckin:checkinId
                                      atVenue:venueId
                                 withVenuName:venueName
                                    forPlayer:fbId
                                      gameWon:self.isWon];
    
    // 2. save to GamePlayerRating table and add points for players
    for(NSDictionary *dic in self.evaluatedPlayersArray)
    {
        // Save Ratings
        [appModel savePlayerRatingFromPlayer:fbId
                                                     toPlayer:[[dic objectForKey:@"id"] stringValue]
                                                      forGame:gameId
                                          withOffensiveRating:[[dic objectForKey:@"offenceRating"] intValue]
                                          withDefensiveRating:[[dic objectForKey:@"defenceRating"] intValue]
                                      withSportsmanshipRating:[[dic objectForKey:@"sportsmanshipRating"] intValue]
                                                  withComment:[dic objectForKey:@"comment"]];
        
        // Adding points for players rated for their skills
        int totalPoints = [[dic objectForKey:@"offenceRating"] intValue] + [[dic objectForKey:@"offenceRating"] intValue] + [[dic objectForKey:@"sportsmanshipRating"] intValue];
        
        [appModel addPoints:totalPoints toUser:[[dic objectForKey:@"id"] stringValue] withCode:CODE_SKILLS];
        
    }
    
    
    // 3. Add points for the rated players
    [appModel addPoints:POINTS_RATING toUser:fbId withCode:CODE_RATING];
    
    if(self.isWon){
        [appModel addPoints:POINTS_WIN toUser:fbId withCode:CODE_WIN];
    }
    
    // 4. Save to news feed
    NSString *name = [appModel.myFbInfo objectForKey:@"name"];
    NSString *news = [NSString stringWithFormat:@"%@ just played a game at %@", name, venueName];
    [appModel postNewsFeed:news fromPlayer:fbId withPlayerName:name withPriority:PRIORITY_MEDIUM];
    
    self.gameSaved = YES;
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


@end

//
//  GameDetailViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-07-30.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "GameDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppModel.h"
#import "PlayerCell.h"
#import "PlayerProfileViewController.h"


@interface GameDetailViewController ()<UITableViewDelegate, UITableViewDataSource, AppModeDelegate>
@property (weak, nonatomic) IBOutlet UIView *didYouWinView;
@property (weak, nonatomic) IBOutlet UILabel *didYouWinLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) int selectedRow;

@property (strong, nonatomic) NSArray *players;
@end

@implementation GameDetailViewController

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
    NSString *gameId = [self.gamePlayersDic objectForKey:@"gameId"];
    [((AppModel*)[AppModel sharedInstance]) getPlayersForGame:gameId fromSender:self];
    
    self.didYouWinView.layer.cornerRadius = 5.f;
    self.didYouWinView.backgroundColor = self.defaultSecondaryColor;
    
    self.tableView.layer.cornerRadius = 5.f;
    
    BOOL didWinGame = [[self.gamePlayersDic objectForKey:@"gameWon"] boolValue];
    if(didWinGame){
        self.didYouWinLabel.text = @"YES";
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((PlayerProfileViewController*)segue.destinationViewController).playerDic = [self.players objectAtIndex:self.selectedRow];
}

#pragma mark - AppModel delegate
-(void)receivedGamePlayers:(NSArray *)players
{
    NSLog(@"Player for game: %@", players);
    [((AppModel*)[AppModel sharedInstance]) getFbProfilesForPlayers:players useKeyName:@"toPlayerId" fromSender:self]; // toPlayerId
}

-(void)receivedPlayerFbProfiles:(NSArray *)playerFbProfiles
{
    self.players = playerFbProfiles;
    [self.tableView reloadData];
}

#pragma mark - UITablieView delegate and datasource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.players.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerCell *cell;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"PLAYER_CELL"];
    if(!cell){
        cell = [[PlayerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PLAYER_CELL"];
    }
    if(self.players){
        cell.playerDic = [self.players objectAtIndex:indexPath.row];
        [cell reloadData];
    }
    return cell;}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRow = indexPath.row;
    [self performSegueWithIdentifier:@"PLAYER_PROFILE" sender:self];
}

@end

//
//  MapVenuePlayersViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-08-15.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "MapVenuePlayersViewController.h"
#import "VenuPlayerCell.h"
#import "PlayerProfileViewController.h"

@interface MapVenuePlayersViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) VenuPlayerCell *selectedCell;

@end

@implementation MapVenuePlayersViewController
@synthesize venueDic = _venueDic;
@synthesize playersLookupDic = _playersLookupDic;

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
    self.title = [self.venueDic objectForKey:@"venueName"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView Delegate and Datasource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray *)[self.venueDic objectForKey:@"players"]).count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NEWS_FEED_CELL
    VenuPlayerCell *cell;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"VENUE_PLAYER_CELL"];
    if(!cell){
        cell = [[VenuPlayerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VENUE_PLAYER_CELL"];
    }
    cell.playerDic = [[self.venueDic objectForKey:@"players"] objectAtIndex:indexPath.row];
    cell.playerProfile = [self.playersLookupDic objectForKey:[cell.playerDic objectForKey:@"fbUserId"]];
    [cell reloadCell];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCell = (VenuPlayerCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"VENUE_TO_PLAYER_SEGUE" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((PlayerProfileViewController *)segue.destinationViewController).playerFbId = [self.selectedCell.playerDic objectForKey:@"fbUserId"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ccc h:mma"];
    NSString *dateString = [dateFormatter stringFromDate:[self.selectedCell.playerDic objectForKey:@"checkInTime"]];
    NSString *checkinMessage = [NSString stringWithFormat:@"\"%@\" - %@ at %@", [self.selectedCell.playerDic objectForKey:@"checkinMessage"], dateString, [self.venueDic objectForKey:@"venueName"] ];
    
    ((PlayerProfileViewController *)segue.destinationViewController).status = checkinMessage;
}


@end

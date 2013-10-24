//
//  ViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-04-16.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "ViewController.h"
#import "IIViewDeckController.h"
#import "LeftMenuViewController.h"
#import "TeamViewController.h"
#import "NewsFeedCell.h"
#import "PlayerProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "ODRefreshControl.h"

@interface ViewController ()<UITabBarControllerDelegate, UITableViewDataSource, AppModeDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *newsFeed;
@property (nonatomic) int selectedStoryIndex;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //LeftMenuViewController *leftMenuViewController = [[LeftMenuViewController alloc] initWithNibName:@"LeftMenuViewController" bundle:nil];
    //self.viewDeckController.leftController = leftMenuViewController;
    [[AppModel sharedInstance] getNewsFeedFromSender:self];
    self.tableView.layer.cornerRadius = 5.f;
    
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];

}

-(void)dropViewDidBeginRefreshing:(ODRefreshControl*)refreshControl
{
    self.runSpinner = NO; // since ODRefreshControl has it's own spinner
    [[AppModel sharedInstance] getNewsFeedFromSender:self];
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

#pragma mark - AppModelDelegate Methods
-(void)receivedNewsFeed:(NSArray *)newsFeed
{
    self.newsFeed = newsFeed;
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

#pragma mark - UITableView Delegate and Datasource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.newsFeed.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NEWS_FEED_CELL
    NewsFeedCell *cell;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"NEWS_FEED_CELL"];
    if(!cell){
        cell = [[NewsFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NEWS_FEED_CELL"];
    }
    
    cell.newsView.backgroundColor = self.defaultSecondaryColor;
    cell.dataObj = [self.newsFeed objectAtIndex:indexPath.row];
    [cell reloadCell];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedStoryIndex = indexPath.row;
    [self performSegueWithIdentifier:@"NEWSFEED_PROFILE_SEGUE" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PlayerProfileViewController *destiniationController = segue.destinationViewController;
    destiniationController.playerFbId = [[self.newsFeed objectAtIndex:self.selectedStoryIndex] objectForKey:@"fromPlayerId"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate *newsDate = ((PFObject*)[self.newsFeed objectAtIndex:self.selectedStoryIndex]).createdAt;
    NSString *dateString = [dateFormatter stringFromDate:newsDate];
    
    NSString *statusMessage = [NSString stringWithFormat:@"\"%@\" - %@", [[self.newsFeed objectAtIndex:self.selectedStoryIndex] objectForKey:@"newsfeed"], dateString];
    destiniationController.status = statusMessage;
}

@end

//
//  PlayerCommentsViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-07-22.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "PlayerCommentsViewController.h"
#import "AppModel.h"
#import <Parse/Parse.h>
#import "PlayerCommentCell.h"
#import "PlayerCommentDetailViewController.h"


@interface PlayerCommentsViewController ()<AppModeDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *commentsArray;
@property (nonatomic) int selectedIndex;

@end

@implementation PlayerCommentsViewController
@synthesize playerDic = _playerDic;

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
    // with playerId in playerDic, go to Parse to get the comments
    
    self.title = [NSString stringWithFormat:@"Players' Comments"];

    
    if([[self.playerDic objectForKey:@"id"] isKindOfClass:[NSString class]]){
        [[AppModel sharedInstance] getCommentsForPlayer:[self.playerDic objectForKey:@"id"] fromSender:self];
    }else{
        [[AppModel sharedInstance] getCommentsForPlayer:[[self.playerDic objectForKey:@"id"] stringValue] fromSender:self];
    }
    
    
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dropViewDidBeginRefreshing:(ODRefreshControl*)refreshControl
{
    self.runSpinner = NO; // since ODRefreshControl has it's own spinner
    if([[self.playerDic objectForKey:@"id"] isKindOfClass:[NSString class]]){
        [[AppModel sharedInstance] getCommentsForPlayer:[self.playerDic objectForKey:@"id"] fromSender:self];
    }else{
        [[AppModel sharedInstance] getCommentsForPlayer:[[self.playerDic objectForKey:@"id"] stringValue] fromSender:self];
    }
}

// comments is an array of PFObject
-(void)receivedPlayerComments:(NSArray *)comments
{
    // comments is an array of PFObjects
    
    NSLog(@"Comments: %@", comments);
    self.commentsArray = comments;
    [[AppModel sharedInstance] getFbProfilesForPlayers:comments useKeyName:@"fromPlayerId" fromSender:self]; // fromPlayerId
}

-(void)receivedPlayerFbProfiles:(NSArray *)playerFbProfiles
{
    NSLog(@"Commenters: %@", playerFbProfiles);
    
    // need to merge commentsArray with playerFBProfiles
    for(PFObject *comment in self.commentsArray){
        NSString *commenterId = [comment objectForKey:@"fromPlayerId"];
        for(NSDictionary *aPlayer in playerFbProfiles){
            NSString *userId = [[aPlayer objectForKey:@"id"] stringValue];
            if([userId isEqualToString:commenterId]){
                NSString *name = [aPlayer objectForKey:@"name"];
                NSString *pic_url = [aPlayer objectForKey:@"pic_square"];
                NSString *pic_original = [aPlayer objectForKey:@"pic"];
                [comment setValue:name forKey:@"name"];
                [comment setValue:pic_url forKey:@"pic"];
                [comment setValue:pic_original forKey:@"pic_original"];
                break;
            }
        }
        
    }
    
    [self.refreshControl endRefreshing];

    [self.tableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((PlayerCommentDetailViewController *)segue.destinationViewController).commentRating = [self.commentsArray objectAtIndex:self.selectedIndex];
}

#pragma mark - UITableView Delegate and Datasource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.commentsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerCommentCell *cell;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"PLAYER_COMMENT_CELL"];
    if(!cell){
        cell = [[PlayerCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PLAYER_COMMENT_CELL"];
    }
    if(self.commentsArray){
        cell.playerObj = [self.commentsArray objectAtIndex:indexPath.row];
        [cell reloadData];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"COMMENT_DETAIL_SEGUE" sender:self];
}


@end

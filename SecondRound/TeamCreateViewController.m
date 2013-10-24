//
//  TeamCreateViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-04-16.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "TeamCreateViewController.h"
#import "TeamInfoCell.h"
#import "MemberCell.h"
#import "TeamSelectMemberViewController.h"
#import <QuartzCore/QuartzCore.h>

#define TEAM_INFO_CELL_ID @"TeamInfo"
#define MEMBER_CELL_ID @"Member"
#define TEAM_INFO_TABLE_SECTIONS 1
#define TEAM_INFO_TABLE_ROWS 2
#define TEAM_NAME_CELL_HEIGHT 44


@interface TeamCreateViewController ()<UITableViewDataSource, UITableViewDelegate, TeamInfoCellDelegate, TeamSelectMemberControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *teamInfoTableView;
@property (weak, nonatomic) IBOutlet UITableView *teamMemberTableView;
@property (weak, nonatomic) TeamInfoCell *teamDetailCell;

@end

@implementation TeamCreateViewController

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
    self.teamInfoTableView.layer.cornerRadius = 10;
    self.teamMemberTableView.layer.cornerRadius = 10;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((TeamSelectMemberViewController*)segue.destinationViewController).delegate = self;
}



#pragma mark - IBAction
- (IBAction)cancelButtonClicked:(id)sender
{
    [self.delegate teamCreateCancelled];
}

- (IBAction)doneButtonClicked:(id)sender
{
    [self.delegate teamCreateCompleted];
}

#pragma mark - UITableView Delegates

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.teamInfoTableView){
        return TEAM_INFO_TABLE_SECTIONS;
    }else{
        return 1; // TO BE IMPLEMENTED
    }
}


-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.teamInfoTableView){
        return TEAM_INFO_TABLE_ROWS;

    }else{
        return 1; // TO BE IMPLEMENTED
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.teamInfoTableView)
    {
        TeamInfoCell* cell = [tableView dequeueReusableCellWithIdentifier:TEAM_INFO_CELL_ID];
        if(!cell){
            cell = [[TeamInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TEAM_INFO_CELL_ID];
        }
        
        if(indexPath.row == 0){
            cell.cellType = TEAM_NAME_CELL;
            cell.delegate = self;
            
        }else{
            cell.cellType = TEAM_DETAIL_CELL;
            self.teamDetailCell = cell;
        }
        
        [cell updateCell];
        return cell;
    }else{
        MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:MEMBER_CELL_ID];
        if(!cell){
            cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MEMBER_CELL_ID];
        }
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.teamInfoTableView)
    {
        if(indexPath.row == 0)
            return TEAM_NAME_CELL_HEIGHT;
        else
            return tableView.frame.size.height - TEAM_NAME_CELL_HEIGHT;
    }
    return 44;
}

#pragma mark - TeamInfoCellDelegate delegate methods
-(void)nextButtonPressed
{
    [self.teamDetailCell.teamInfoTextView becomeFirstResponder];
}

#pragma mark - TeamSelectMemberControllerDelegate delegate methods
-(void)selectMemberCancel
{
    [self dismissViewControllerAnimated:YES completion:^(void){}]; 
}

-(void)selectMemberDone
{
    [self dismissViewControllerAnimated:YES completion:^(void){}]; 
}



@end

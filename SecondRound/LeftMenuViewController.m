//
//  LeftMenuViewController.m
//  Second Date
//
//  Created by Eugene Lin on 13-04-11.
//  Copyright (c) 2013 Second Date. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "LeftViewSelectionCell.h"
#import "AppDelegate.h"
#import "IIViewDeckController.h"
#import "TeamViewController.h"

@interface LeftMenuViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *LeftMenuTable;

@end

@implementation LeftMenuViewController

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
    // Do any additional setup after loading the view from its nib.
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View Data Source and Delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTIONS;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return SECTION0_ROWS;
    }else{
        return 1; // JUST SHOW TBD
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LeftViewSelectionCell *cell = [self.LeftMenuTable dequeueReusableCellWithIdentifier:@"LeftSelectionCell"];
    
    
    if(!cell){
        
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LeftViewSelectionCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (LeftViewSelectionCell *)currentObject;
                break;
            }
        }

    }

    if(indexPath.section == 0){
        switch(indexPath.row){
            case 0:
                cell.cellLabel.text = SECTION0_ROW0;
                cell.subLabel.text = SECTION0_ROW0_SUB;
                break;
            case 1:
                cell.cellLabel.text = SECTION0_ROW1;
                cell.subLabel.text = SECTION0_ROW1_SUB;
                break;
            case 2:
                cell.cellLabel.text = SECTION0_ROW2;
                cell.subLabel.text = SECTION0_ROW2_SUB;
                break;
            case 3:
                cell.cellLabel.text = SECTION0_ROW3;
                cell.subLabel.text = SECTION0_ROW3_SUB;
                break;
            case 4:
                cell.cellLabel.text = SECTION0_ROW4;
                cell.subLabel.text = SECTION0_ROW4_SUB;
                break;
            //case 5:
            //    cell.cellLabel.text = SECTION0_ROW5;
            //    break;
            default:
                break;
        }
    }else{
        cell.cellLabel.text = @"To be implemented";
    }
    
    cell.leftCellView.layer.cornerRadius = 5.f;
    //cell.leftCellView.backgroundColor = [UIColor colorWithRed:SECOND_RED green:SECOND_GREEN blue:SECOND_BLUE alpha:1.0];
    
    return cell;
}

/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch(section){
        case 0:
            return SECTION0_TITLE;
            break;
        case 1:
            return SECTION1_TITLE;
            break;
        case 2:
            return SECTION2_TITLE;
            break;
        default:
            break;
    }
    return @"";
}
*/


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        LeftViewSelectionCell *cell = (LeftViewSelectionCell*)[self.LeftMenuTable cellForRowAtIndexPath:indexPath];
        NSString *labelText = cell.cellLabel.text;
        if([labelText isEqualToString:NEWS_FEED]){
            // To be implemented
            [self.delegate switchToViewWithId:NEWS_FEED_VIEW_ID];
        }else if([labelText isEqualToString:MAP]){
            [self.delegate switchToViewWithId:MAP_VIEW_ID];

        }else if([labelText isEqualToString:GAMES]){
            [self.delegate switchToViewWithId:GAME_VIEW_ID];
            
        }else if([labelText isEqualToString:PLAYERS]){
            [self.delegate switchToViewWithId:PLAYER_VIEW_ID];
            
        }else if([labelText isEqualToString:SIGNOUT]){
            // To be implemented
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate closeSession];
            
            if([self.delegate isKindOfClass:[BaseMemberViewController class]]){
                NSLog(@"display login view please!");
                [(BaseMemberViewController*)self.delegate displayLogin];
            }
            
        }else{
            
        }
    }
    
    [self.viewDeckController toggleLeftViewAnimated:YES];
}



@end

//
//  PlayerProfileViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-06-26.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "PlayerProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppModel.h"
#import "DYRateView.h"
#import "PlayerCommentsViewController.h"


@interface PlayerProfileViewController ()<AppModeDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *starRatingView;
@property (strong, nonatomic) DYRateView *offenceRateView;
@property (strong, nonatomic) DYRateView *defenceRateView;
@property (strong, nonatomic) DYRateView *sportsmanshipRateView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *seasonScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *careerScoreLabel;
@property (weak, nonatomic) IBOutlet UIView *scoreView;
@property (weak, nonatomic) IBOutlet UITextView *statusTextView;
@end

@implementation PlayerProfileViewController

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
    
    self.statusTextView.backgroundColor = self.defaultBackgroundColor;
    
	// Do any additional setup after loading the view.
    
    // !!! First, setup general look and feel without referring to the player's info !!!
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    //self.imageView.contentMode = UIViewContentModeScaleToFill;
    self.imageView.layer.borderWidth = 2.0;
    self.imageView.layer.cornerRadius = 5.0f;
    self.imageView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    self.scoreView.backgroundColor = self.defaultBackgroundColor;
    
    // *** star rating
    self.offenceRateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 30, 280, 20) fullStar:[UIImage imageNamed:@"StarFullLarge.png"] emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];
    
    self.offenceRateView.rate = 0;
    self.offenceRateView.padding = 30;
    self.offenceRateView.alignment = RateViewAlignmentLeft;
    self.offenceRateView.editable = NO;
    
    self.defenceRateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 95, 280, 20) fullStar:[UIImage imageNamed:@"StarFullLarge.png"] emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];
    
    self.defenceRateView.rate = 0;
    self.defenceRateView.padding = 30;
    self.defenceRateView.alignment = RateViewAlignmentLeft;
    self.defenceRateView.editable = NO;
    
    self.sportsmanshipRateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 160, 280, 20) fullStar:[UIImage imageNamed:@"StarFullLarge.png"] emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];
    
    self.sportsmanshipRateView.rate = 0;
    self.sportsmanshipRateView.padding = 30;
    self.sportsmanshipRateView.alignment = RateViewAlignmentLeft;
    self.sportsmanshipRateView.editable = NO;
    
    [self.starRatingView addSubview:self.offenceRateView];
    [self.starRatingView addSubview:self.defenceRateView];
    [self.starRatingView addSubview:self.sportsmanshipRateView];
    self.starRatingView.backgroundColor = self.defaultBackgroundColor;
    
    
    
    // !!! 2. begin to populate specific info !!!
    if(self.playerDic){
        [self populatePlayerProfile]; // passed in by the caller
    }else{
        // we need to grab player dic ourself!
        [NSArray arrayWithObject:self.playerFbId];
        [[AppModel sharedInstance] getFbProfileForAllPlayers:[NSArray arrayWithObject:self.playerFbId] fromSender:self];
    }
}

// we grabbed player's dic ourself
-(void)receivedAllPlayerFbProfiles:(NSArray *)fbPlayerProfiles
{
    self.playerDic = [fbPlayerProfiles objectAtIndex:0];
    [self populatePlayerProfile];
}

-(void)populatePlayerProfile
{
    // a. Get the player's image and name
    NSString *url = [self.playerDic objectForKey:@"pic"];
    [self.imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"secondround_icon.png"]];
    self.nameLabel.text = [self.playerDic objectForKey:@"name"];
    
    
    // b. Get avg stars
    [self calculateAvgRatings];
    
    // c. Get Total Score and Season Score
    NSString *fbUserId;
    if([[self.playerDic objectForKey:@"id"] isKindOfClass:[NSString class]]){
        fbUserId = [self.playerDic objectForKey:@"id"];
    }else{
        fbUserId = [[self.playerDic objectForKey:@"id"] stringValue];
    }
    [[AppModel sharedInstance] getSeasonUserPointsRankingForUser:fbUserId fromSender:self];
    [[AppModel sharedInstance] getCareerUserPointsForUser:fbUserId fromSender:self];
    
    // d. Get Ranking
    [[AppModel sharedInstance] updateRankingForUser:fbUserId fromSender:self];
    
    // e. if there's a player status, lets show it
    if(self.status){
        self.statusTextView.text = [NSString stringWithFormat:@"%@",self.status];
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    // sned playerDic info to segue.destinationViewController
    ((PlayerCommentsViewController*)segue.destinationViewController).playerDic = self.playerDic;
    
}

-(void)calculateAvgRatings
{
    AppModel* appModel = [AppModel sharedInstance];
    if([[self.playerDic objectForKey:@"id"] isKindOfClass:[NSString class]]){
        [appModel getRatingsForPlayer:[self.playerDic objectForKey:@"id"] forSender:self];
    }else{
        [appModel getRatingsForPlayer:[[self.playerDic objectForKey:@"id"] stringValue] forSender:self];
    }
}

-(void)avgRatingOffence:(float)offensiveRating andDefence:(float)defensiveRating andSportsmanship:(float)sportsmanshipRating withCount:(int)count
{
    NSLog(@"Offensive: %f, Defensive: %f, Sportsmanship: %f, count: %d", offensiveRating, defensiveRating, sportsmanshipRating, count);
    self.offenceRateView.rate = offensiveRating;
    self.defenceRateView.rate = defensiveRating;
    self.sportsmanshipRateView.rate = sportsmanshipRating;
}

-(void)rank:(NSNumber*)rank forUser:(NSString *)fbUserId
{
    self.rankLabel.text = [rank stringValue];
}

-(void)seasonPoints:(NSNumber*)points andRanking:(NSNumber*)ranking forUser:(NSString *)fbUserId
{
    self.rankLabel.text = [ranking stringValue];
    self.seasonScoreLabel.text = [points stringValue];
}

-(void)careerPoints:(NSNumber *)points forUser:(NSString *)fbUserId
{
    self.careerScoreLabel.text = [points stringValue];
}

@end

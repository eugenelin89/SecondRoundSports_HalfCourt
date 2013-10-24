//
//  PlayerCommentDetailViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-07-24.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "PlayerCommentDetailViewController.h"
#import "DYRateView.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "PlayerProfileViewController.h"


@interface PlayerCommentDetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *starRatingView;
@property (strong, nonatomic) DYRateView *offenceRateView;
@property (strong, nonatomic) DYRateView *defenceRateView;
@property (strong, nonatomic) DYRateView *sportsmanshipRateView;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UIImageView *commentorImageView;
@property (weak, nonatomic) IBOutlet UIView *commentorView;
@property (weak, nonatomic) IBOutlet UILabel *commentorLabel;

@end

@implementation PlayerCommentDetailViewController
@synthesize commentRating = _commentRating;

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
    self.title = [NSString stringWithFormat:@"Comment and Rating"];

    
    // star rating
    self.offenceRateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 30, 280, 20) fullStar:[UIImage imageNamed:@"StarFullLarge.png"] emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];
    
    self.offenceRateView.rate = [[self.commentRating objectForKey:@"offensiveRating"] intValue];
    self.offenceRateView.padding = 30;
    self.offenceRateView.alignment = RateViewAlignmentLeft;
    self.offenceRateView.editable = NO;
    
    self.defenceRateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 95, 280, 20) fullStar:[UIImage imageNamed:@"StarFullLarge.png"] emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];
    
    self.defenceRateView.rate = [[self.commentRating objectForKey:@"defensiveRating"] intValue];
    self.defenceRateView.padding = 30;
    self.defenceRateView.alignment = RateViewAlignmentLeft;
    self.defenceRateView.editable = NO;
    
    self.sportsmanshipRateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 160, 280, 20) fullStar:[UIImage imageNamed:@"StarFullLarge.png"] emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];
    
    self.sportsmanshipRateView.rate = [[self.commentRating objectForKey:@"sportsmanshipRating"] intValue];
    self.sportsmanshipRateView.padding = 30;
    self.sportsmanshipRateView.alignment = RateViewAlignmentLeft;
    self.sportsmanshipRateView.editable = NO;
    
    [self.starRatingView addSubview:self.offenceRateView];
    [self.starRatingView addSubview:self.defenceRateView];
    [self.starRatingView addSubview:self.sportsmanshipRateView];
    self.starRatingView.backgroundColor = self.defaultBackgroundColor;
    

    
    // text view
    self.commentTextView.editable = NO;
    self.commentTextView.text = [NSString stringWithFormat:@"\"%@\"\n - %@", [self.commentRating objectForKey:@"comment"], [self.commentRating objectForKey:@"name"]];
    self.commentTextView.backgroundColor = self.defaultSecondaryColor;
    self.commentTextView.layer.cornerRadius = 5.f;
    
    // commentor view and imageView
    self.commentorView.backgroundColor = self.defaultSecondaryColor;
    self.commentorView.layer.cornerRadius = 5.f;
    self.commentorImageView.layer.borderWidth = 0.0;
    self.commentorImageView.layer.cornerRadius = 5.0f;
    self.commentorImageView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    NSString *url = [self.commentRating objectForKey:@"pic"];
    [self.commentorImageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"secondround_icon.png"]];
    
    UITapGestureRecognizer *tapViewRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(viewTapped:)];
    [self.commentorView addGestureRecognizer:tapViewRecognizer];
    
    self.commentorLabel.text = [NSString stringWithFormat:@"%@'s Profile", [self.commentRating objectForKey:@"name"]];
}

-(void)viewTapped:(UIGestureRecognizer *)gestureRecognizer
{
    [self performSegueWithIdentifier:@"COMMENTOR_PROFILE_SEGUE" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // we need id, pic_square, name
    NSString *playerId = [self.commentRating objectForKey:@"fromPlayerId"];
    NSString *name = [self.commentRating objectForKey:@"name"];
    NSString *pic = [self.commentRating objectForKey:@"pic_original"];
    
    NSArray *valueArray = [[NSArray alloc] initWithObjects:playerId,name,pic, nil];
    NSArray *keyArray = [[NSArray alloc] initWithObjects:@"id",@"name",@"pic", nil];
    NSDictionary *playerDic = [[NSDictionary alloc] initWithObjects:valueArray forKeys:keyArray];
    
    ((PlayerProfileViewController *)segue.destinationViewController).playerDic = playerDic;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

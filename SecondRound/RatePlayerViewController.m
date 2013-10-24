
//
//  RatePlayerViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-06-15.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "RatePlayerViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "DYRateView.h"

@interface RatePlayerViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *starRatingsView;
@property (strong, nonatomic) DYRateView *offenceRateView;
@property (strong, nonatomic) DYRateView *defenceRateView;
@property (strong, nonatomic) DYRateView *sportsmanshipRateView;
@property (weak, nonatomic) IBOutlet UIView *commentSubview;

@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (nonatomic) BOOL isKeyboardDisplayed;
@property (nonatomic) BOOL textViewIsClean;

@end

@implementation RatePlayerViewController

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
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    //self.imageView.contentMode = UIViewContentModeScaleToFill;
    self.imageView.layer.borderWidth = 2.0;
    self.imageView.layer.cornerRadius = 5.0f;
    self.imageView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    
    NSString *url = [self.playerDic objectForKey:@"pic"];
    [self.imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"secondround_icon.png"]];
    self.nameLabel.text = [self.playerDic valueForKey:@"name"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    self.commentTextView.returnKeyType = UIReturnKeyDone;
    self.commentTextView.layer.borderWidth = 0.5;
    //[self resetTextView];
    
    
    // star rating
    self.offenceRateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 30, 280, 20) fullStar:[UIImage imageNamed:@"StarFullLarge.png"] emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];

    self.offenceRateView.rate = 0;
    self.offenceRateView.padding = 30;
    self.offenceRateView.alignment = RateViewAlignmentLeft;
    self.offenceRateView.editable = YES;
    
    self.defenceRateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 95, 280, 20) fullStar:[UIImage imageNamed:@"StarFullLarge.png"] emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];

    self.defenceRateView.rate = 0;
    self.defenceRateView.padding = 30;
    self.defenceRateView.alignment = RateViewAlignmentLeft;
    self.defenceRateView.editable = YES;
    
    self.sportsmanshipRateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 160, 280, 20) fullStar:[UIImage imageNamed:@"StarFullLarge.png"] emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];
    
    self.sportsmanshipRateView.rate = 0;
    self.sportsmanshipRateView.padding = 30;
    self.sportsmanshipRateView.alignment = RateViewAlignmentLeft;
    self.sportsmanshipRateView.editable = YES;
    
    [self.starRatingsView addSubview:self.offenceRateView];
    [self.starRatingsView addSubview:self.defenceRateView];
    [self.starRatingsView addSubview:self.sportsmanshipRateView];
    self.starRatingsView.backgroundColor = self.defaultBackgroundColor;
    self.navBar.tintColor = self.defaultNavBarColor;
    
    NSDictionary *rateDic = [self.playerDic objectForKey:@"rateDic"];
    if(rateDic){
        self.offenceRateView.rate = [[rateDic objectForKey:@"offenceRating"] floatValue];
        self.defenceRateView.rate = [[rateDic objectForKey:@"offenceRating"] floatValue];
        self.sportsmanshipRateView.rate = [[rateDic objectForKey:@"sportsmanshipRating"] doubleValue];
        if([rateDic objectForKey:@"comment"]){
            self.commentTextView.text = [rateDic objectForKey:@"comment"];
        }
    }
    if(!self.commentTextView.text || [[self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
        [self resetTextView];
    }

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.delegate cancelRatePlayer];
}
- (IBAction)doneButtonPressed:(id)sender {
    NSMutableDictionary *rateDic = [[NSMutableDictionary alloc] init];
    [rateDic setValue:[NSNumber numberWithFloat:self.offenceRateView.rate] forKey:@"offenceRating"];
    [rateDic setValue:[NSNumber numberWithFloat:self.defenceRateView.rate] forKey:@"defenceRating"];
    [rateDic setValue:[NSNumber numberWithFloat:self.sportsmanshipRateView.rate] forKey:@"sportsmanshipRating"];
    if(![self.commentTextView.text isEqualToString:DEFAULT_PLAYER_RATING_COMMENT])
        [rateDic setValue:self.commentTextView.text forKey:@"comment"];
    [rateDic setValue:[self.playerDic objectForKey:@"id"] forKey:@"id"];
    [rateDic setValue:[self.playerDic objectForKey:@"name"] forKey:@"name"];
    
    // Note, the way it works is that the original dic will have a pointer to this new dic
    [self.playerDic setValue:rateDic forKey:@"rateDic"];
    [self.delegate finishRatePlayer:rateDic];
}

#pragma mark - UITextViewDelegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return true;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if(!self.textViewIsClean && [[self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
        [self resetTextView];
    }
    return true;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }else{
        if(self.textViewIsClean){
            self.textViewIsClean = NO;
            textView.text = @"";
            textView.textColor = [UIColor blackColor];
        }
        // For any other character return TRUE so that the text gets added to the view
        return TRUE;
    }
}

#pragma mark - Keyboard Notifications
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect subviewFrame = CGRectMake(self.commentSubview.frame.origin.x, self.commentSubview.frame.origin.y - kbSize.height, self.commentSubview.frame.size.width, self.commentSubview.frame.size.height);
    
    
    
    [UIView animateWithDuration:0.25 delay:0 options:0 animations:^{
        
        [self.commentSubview setFrame:subviewFrame];
        
        
    }completion:^(BOOL finished){
        if(finished){
            //self.commentSubview.alpha = 0.7;
            self.isKeyboardDisplayed = YES;
            [self.commentTextView setSelectedRange:NSMakeRange(0, 0)];

        }
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
    CGRect subviewFrame = CGRectMake(self.commentSubview.frame.origin.x, 375, self.commentSubview.frame.size.width, self.view.frame.size.height - 375 - 15);
    [UIView animateWithDuration:0.25 delay:0 options:0 animations:^{
        
        [self.commentSubview setFrame:subviewFrame];
        
        
    }completion:^(BOOL finished){
        //if(finished){
        self.commentSubview.alpha = 1.0;
        self.isKeyboardDisplayed = NO;
        //}
    }];
    
}

#pragma mark - Private Helper Function
-(void)resetTextView
{
    self.commentTextView.text = DEFAULT_PLAYER_RATING_COMMENT;
    self.commentTextView.textColor = [UIColor lightGrayColor];
    self.textViewIsClean = YES;
}

@end

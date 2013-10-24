//
//  MapViewController.m
//  SecondRound
//
//  Created by Eugene Lin on 13-06-06.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MapViewController.h"
#import "IIViewDeckController.h"
#import "PlaceViewCell.h"
#import "AppModel.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CheckedInViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "CheckInAnnotation.h"
#import "MapVenuePlayersViewController.h"


#define MAP_HEIGHT 220
#define MAP_DELTA_LAT  0.0012537
#define MAP_DELTA_LONG 0.0064658

@interface MapViewController ()<UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UITextViewDelegate, CheckedInViewControllerDelegate, AppModeDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSDictionary *checkinVenuInfo;
@property (strong, nonatomic) UIBarButtonItem *checkinButtonRef;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *checkinButton;
@property (weak, nonatomic) IBOutlet UIView *checkinSubView;
@property (weak, nonatomic) IBOutlet UIButton *checkinConfirmButton;
@property (weak, nonatomic) IBOutlet UITextView *checkinMessageTextView;


// Flags
@property (nonatomic) Boolean isFullMap; // map is full screen
@property (nonatomic) Boolean isCheckinIn; // subview for check in detail visible
@property (nonatomic) Boolean isKeyboardDisplayed; // keyboard visible
@property (nonatomic) BOOL textViewIsClean;

// Check Ins
@property (strong, nonatomic) NSArray *checkedInVenues;
@property (strong, nonatomic) CheckInAnnotation* tappedAnnotation;
@property (strong, nonatomic) NSMutableDictionary *allPlayersLookupDic; // Prefetched FB profiles for all checked-in players, key is FbId, so player info is avail seguing into venue-players view.

@end

@implementation MapViewController
@synthesize checkinVenuInfo = _checkinVenuInfo;
@synthesize checkinButtonRef = _checkinButtonRef;
@synthesize annotations = _annotations;
@synthesize mapView = _mapView;
@synthesize checkedInVenues = _checkedInVenues;
@synthesize tappedAnnotation = _tappedAnnotation;



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
    
    // first, get all the nearby checkins asap.
    [[AppModel sharedInstance] getCheckinWithinRadius:NEARBY_RADIUS withinHours:SOMETIME_AGO fromSender:self];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(significantLocationChanged)
     name:SignificantLocationChageNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(foursquareVenueUpdated)
     name:FoursquareVenueUpdated
     object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [self resetTextView];
    // create the map

    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    [self setDisplayRegionToCenter:[[AppModel sharedInstance] currentLocation] withMapSpan:MKCoordinateSpanMake(MAP_DELTA_LAT,MAP_DELTA_LONG) forMap:self.mapView];
    
    self.checkinMessageTextView.returnKeyType = UIReturnKeyDone;
    self.checkinMessageTextView.layer.borderWidth = 0.5;
        
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.mapView setFrame:[self.view frame]];
    CGRect tableFrame = CGRectMake(0,self.view.frame.size.height,self.view.frame.size.width, self.view.frame.size.height - MAP_HEIGHT);
    [self.tableView setFrame: tableFrame];
    CGRect subviewFrame = CGRectMake(self.view.frame.size.width,MAP_HEIGHT,self.view.frame.size.width, self.view.frame.size.height - MAP_HEIGHT);
    [self.checkinSubView setFrame:subviewFrame];
    
    
    
    if(((AppModel*)[AppModel sharedInstance]).mapToCheckin){
        [self resizeMapToHalf];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ((AppModel*)[AppModel sharedInstance]).mapToCheckin = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

-(void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
    
}

-(void)updateMapView
{
    if(self.mapView.annotations){
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    if(self.annotations){
        [self.mapView addAnnotations:self.annotations];
    }
}

-(NSArray*)mapAnnotations
{
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:self.checkedInVenues.count];
    for(NSDictionary *venue in self.checkedInVenues){
        [annotations addObject:[CheckInAnnotation annotationForCheckin:venue]];
    }
    return annotations;
}

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView =nil;
    if(![annotation isKindOfClass:[MKUserLocation class]]){
        aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
        if(!aView){
            aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
            aView.canShowCallout = YES;
            //aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        
        //[(UIImageView*)aView.leftCalloutAccessoryView setImage:nil];
        
        aView.annotation = annotation;
    }
    return aView;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    self.tappedAnnotation = view.annotation;
    [self performSegueWithIdentifier:@"VENUE_PLAYERS_SEGUE" sender:self];

}

-(void)receivedCheckIns:(NSArray *)checkIns
{
    // checkIns is an array of PFOjbect
    // turn into NSDictionary with the following structure:
    // { 
    //   venueId = "4ba92d28f964a520a2113ae3";
    //   venueName = "David Lam Park";
    //   checkinLocation = {49.19920059273802, -122.9794613955216} // PFGeoPoint
    //   players = (mutable array of player dics);
    // }
    // player dics:
    // {
    //   fbUserId = "878390513";
    //   checkinMessage = "Hello!"
    //   checkInTime = "2013-08-14T23:19:25.787Z"
    // }
    
    // we use temp to group venues
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithCapacity:checkIns.count];
    
    // to improve performance when callout button is tapped, we go to Facebook to
    // grab player's name and image URL here and dump it into player dictionary.  Thus,
    // we need an array of all players' FB ID.
    NSMutableArray *allPlayerIds = [[NSMutableArray alloc] initWithCapacity:checkIns.count];
    
    for(PFObject *checkin in checkIns){

        // 1. check if a venue for thie checkin already exist.
        NSString *venueId = [checkin objectForKey:@"venueId"];
        NSDictionary * venueDic = [temp objectForKey:venueId];
        if(!venueDic){
            // venue dic not yet exist, create one.
            NSString *venueName = [checkin objectForKey:@"venueName"];
            PFGeoPoint *checkinLocation = [checkin objectForKey:@"checkinLocation"];
            NSMutableArray *playersArray = [[NSMutableArray alloc] init];
            NSArray *keyArray = @[@"venueId", @"venueName", @"checkinLocation", @"players"];
            NSArray *objArray = @[venueId, venueName, checkinLocation, playersArray];
            venueDic = [[NSDictionary alloc] initWithObjects:objArray forKeys:keyArray];
            // Add venue dic into temp for grouping.
            [temp setObject:venueDic forKey:venueId];
        }
        
        // 2. create a player dic
        NSArray *valueArray = @[[checkin objectForKey:@"fbUserId"], checkin.createdAt, [checkin objectForKey:@"checkinMessage"]];
        NSArray *keyArray = @[@"fbUserId",@"checkInTime", @"checkinMessage"];
        NSDictionary *playerDic = [[NSDictionary alloc] initWithObjects:valueArray forKeys:keyArray];
        
        // 3. add player dic into venue dic's players array
        [((NSMutableArray*)[venueDic objectForKey:@"players"]) addObject:playerDic];
        
        [allPlayerIds addObject:[checkin objectForKey:@"fbUserId"]];
    }
    
    [[AppModel sharedInstance] getFbProfileForAllPlayers:allPlayerIds fromSender:self];
    
    self.checkedInVenues = [temp allValues];
    self.annotations = [self mapAnnotations];
    
}

-(void)receivedAllPlayerFbProfiles:(NSArray *)fbPlayerProfiles
{
    NSLog(@"received all checked in players' profiles: \n%@", fbPlayerProfiles);
    NSMutableDictionary *playersDic = [[NSMutableDictionary alloc] initWithCapacity:fbPlayerProfiles.count];
    for(NSDictionary *playerDic in fbPlayerProfiles){
        [playersDic setObject:playerDic forKey:[[playerDic objectForKey:@"id"] stringValue]];
    }
    self.allPlayersLookupDic = playersDic;
}

- (IBAction)menuButtonClicked:(id)sender
{
    [self.viewDeckController toggleLeftViewAnimated:YES];
}

- (IBAction)checkinButtonClicked:(id)sender
{
    // Powered by Foursquare
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pf" ofType:@"png"];
    //UIImage *creditImage = [[UIImage alloc] initWithContentsOfFile:filePath];
    //UIImageView *creditImageView = [[UIImageView alloc] initWithImage:creditImage];
    //self.navigationItem.titleView = creditImageView;
    //self.title = @"Powered by Foursquare";
    [self resizeMapToHalf];
}

#pragma mark - UITableView Data Source, Delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[AppModel sharedInstance] nearbyVenues] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaceViewCell *cell;

    cell = [self.tableView dequeueReusableCellWithIdentifier:@"PLACE_VIEW"];
    if(!cell){
        cell = [[PlaceViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PLACE_VIEW"];
    }
    [cell updateCellWithInfo:[[[AppModel sharedInstance] nearbyVenues] objectAtIndex:indexPath.row]];
    
    //cell.view.backgroundColor = self.defaultSecondaryColor;
    cell.venueNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.venueNameLabel.numberOfLines = 0;
    //cell.venueNameLabel.textColor = [UIColor whiteColor];
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return self.tableView.rowHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showCheckinSubview];
    self.checkinVenuInfo = ((PlaceViewCell* )[tableView cellForRowAtIndexPath:indexPath]).venuInfo;
}

#pragma mark - IBAction
- (IBAction)doCheckin:(id)sender {
    bool goBackToMyGameView = NO;
    AppModel *appModel = [AppModel sharedInstance];
    if(appModel.myFbInfo){
        NSString* fbId = [[appModel.myFbInfo valueForKey:@"id"] stringValue];
        NSString* msg = self.checkinMessageTextView.text;
        if([msg isEqualToString:DEFAULT_CHECKIN_MESSAGE])
            msg = @"";
        NSString* venueName = [self.checkinVenuInfo valueForKey:@"name"];
        NSString* venueId = [self.checkinVenuInfo valueForKey:@"id"];
        [appModel checkinForUser:fbId withMessage:msg atVenue:venueName withVenueId:venueId];
        [appModel addPoints:POINTS_CHECKIN toUser:fbId withCode:CODE_CHECKIN];
        
        if(((AppModel*)[AppModel sharedInstance]).mapToCheckin){
            // we came from "My Games" and was trying to add game
            // go back to "My Games"
            goBackToMyGameView = YES;
        }
        
    }
    
    //[self performSegueWithIdentifier:@"CHECKED_IN" sender:self];
    [self returnToMap];
    [[AppModel sharedInstance] getCheckinWithinRadius:NEARBY_RADIUS withinHours:SOMETIME_AGO fromSender:self];
    if(goBackToMyGameView){
        [self switchToViewWithId:GAME_VIEW_ID];
    }
        
}


#pragma mark - Text View Delegates
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"textViewShouldBeginEditing");
    
    return true;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if(!self.textViewIsClean && [[self.checkinMessageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[CheckedInViewController class]]){
        ((CheckedInViewController*)segue.destinationViewController).delegate = self;
        [self returnToMap]; // before we segue, lets return the mapview to original state.
    }else if([segue.destinationViewController isKindOfClass:[MapVenuePlayersViewController class]]){
        ((MapVenuePlayersViewController *)segue.destinationViewController).venueDic = self.tappedAnnotation.venue;
        ((MapVenuePlayersViewController *)segue.destinationViewController).playersLookupDic = self.allPlayersLookupDic;
    }
        
}

#pragma mark - CheckedInViewController Delegate
-(void)userAcknowledgedCheckin
{
    [self dismissViewControllerAnimated:YES completion:^(void){
        
    }];
}


#pragma mark - Private Methods

-(void)foursquareVenueUpdated
{
    [self.tableView reloadData];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect subviewFrame = CGRectMake(0, self.checkinSubView.frame.origin.y - kbSize.height, self.checkinSubView.frame.size.width, self.checkinSubView.frame.size.height);
    
    
    
    [UIView animateWithDuration:0.25 delay:0 options:0 animations:^{
        
        [self.checkinSubView setFrame:subviewFrame];
        
        
    }completion:^(BOOL finished){
        if(finished){
            self.checkinSubView.alpha = 0.7;
            self.isKeyboardDisplayed = YES;
            
            [self.checkinMessageTextView setSelectedRange:NSMakeRange(0, 0)];

        }
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{

    CGRect subviewFrame = CGRectMake(0, MAP_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - MAP_HEIGHT);
    [UIView animateWithDuration:0.25 delay:0 options:0 animations:^{
        
        [self.checkinSubView setFrame:subviewFrame];
        
        
    }completion:^(BOOL finished){
        //if(finished){
            self.checkinSubView.alpha = 1.0;
            self.isKeyboardDisplayed = NO;
        //}
    }];
    
}

-(void)hideCheckinSubview
{
    CGRect tableFrame = CGRectMake(0, MAP_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - MAP_HEIGHT);
    CGRect subviewFrame = CGRectMake(self.view.frame.size.width, MAP_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - MAP_HEIGHT);
    
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        
        [self.tableView setFrame:tableFrame];
        [self.checkinSubView setFrame:subviewFrame];
        
        
    }completion:^(BOOL finished){
        if(finished){
            self.isCheckinIn = NO;
            self.checkinVenuInfo = nil;
        }
        [self resizeMapToFull];
        
    }];
}

-(void)showCheckinSubview
{
    CGRect tableFrame = CGRectMake(
                                   0-self.view.frame.size.width,
                                   MAP_HEIGHT,self.view.frame.size.width,
                                   self.view.frame.size.height-MAP_HEIGHT);
    CGRect subviewFrame = CGRectMake(0, MAP_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - MAP_HEIGHT);
    
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        
        [self.tableView setFrame:tableFrame];
        [self.checkinSubView setFrame:subviewFrame];
                
        
    }completion:^(BOOL finished){
        if(finished){
            self.isCheckinIn = YES;
        }
        
    }];
}

-(void)cancelButtonClicked
{

    self.navigationItem.titleView = nil;
    
    [self returnToMap];
}

-(void)returnToMap
{
    if(self.isKeyboardDisplayed){
        [self.checkinMessageTextView resignFirstResponder];
        [self hideCheckinSubview];
    }else if(self.isCheckinIn){
        // We are displaying the subview for checking into the venue.
        // should just move the subview out and move the table view back in.
        [self hideCheckinSubview];
        
    }else{
        // We ware displaying half map view and half table view.
        // Should just display full map view.
        [self resizeMapToFull];
    }
}

-(void)resizeMapToHalf
{
    CGRect mapFrame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, MAP_HEIGHT);
    CGRect tableFrame = CGRectMake(0,MAP_HEIGHT,self.view.frame.size.width, self.view.frame.size.height - MAP_HEIGHT);
    
    self.checkinButtonRef = self.checkinButton;
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked)];
    self.navigationItem.rightBarButtonItem = button;
    
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        
        
        [self.mapView setFrame:mapFrame];
        [self.tableView setFrame:tableFrame];
        
        
        
    }completion:^(BOOL finished){
        if(finished){
            self.isFullMap = NO;
        }
    }];
}


-(void)resizeMapToFull
{
    
    CGRect mapFrame = [self.view frame];
    CGRect tableFrame = CGRectMake(0,self.view.frame.size.height,self.view.frame.size.width, self.view.frame.size.height - MAP_HEIGHT);

    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        
        
        [self.mapView setFrame:mapFrame];
        [self.tableView setFrame:tableFrame];
        
        
        
    }completion:^(BOOL finished){
        if(finished){
            self.isFullMap = YES;
        }
        
    }];
    
    if(self.checkinButtonRef){
        self.navigationItem.rightBarButtonItem = self.checkinButtonRef;
    }
}

-(void)significantLocationChanged
{
    NSLog(@"significantLocationChange notification detected");
    CLLocationCoordinate2D currentLocation = [[AppModel sharedInstance] currentLocation];
    [self setDisplayRegionToCenter:currentLocation withMapSpan:MKCoordinateSpanMake(MAP_DELTA_LAT,MAP_DELTA_LONG) forMap:self.mapView];
    
    // need to get from Foursquare all the venues
    
}

-(void)setDisplayRegionToCenter:(CLLocationCoordinate2D)center
                    withMapSpan:(MKCoordinateSpan)mapSpan
                         forMap:(MKMapView *)mapView
{
    // Create location coordinate from the location parameter
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = center.latitude;
    zoomLocation.longitude = center.longitude;
    
    // Setup region
    MKCoordinateRegion viewRegion = MKCoordinateRegionMake(zoomLocation, mapSpan);
    //MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion]; // could produce NAN which cause setRegion to crash.
    
    // Move map to location
    [mapView setRegion:viewRegion animated:YES];
}

-(void)resetTextView
{
    self.checkinMessageTextView.text = DEFAULT_CHECKIN_MESSAGE;
    self.checkinMessageTextView.textColor = [UIColor lightGrayColor];
    self.textViewIsClean = YES;
}


@end

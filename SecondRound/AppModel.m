//
//  AppModel.m
//  Caribbean
//
//  Created by Eugene Lin on 13-01-23.
//  Copyright (c) 2013 Eugene Lin. All rights reserved.
//
#import <Parse/Parse.h>
#import "AppModel.h"
#import "AFJSONRequestOperation.h"
#import "AppDelegate.h"




@interface AppModel()<CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation AppModel
@synthesize currentLocation = _currentLocation;
@synthesize nearbyVenues = _nearbyVenues;
@synthesize myFbInfo = _myFbInfo;
@synthesize checkinInfo = _checkinInfo;
@synthesize userApproved = _userApproved;


#pragma mark - Public Methods

-(void)getCheckinWithinRadius:(double)miles withinHours:(int)hours fromSender:(id<AppModeDelegate>)sender
{
    [self startSpinnerForSender:sender];
    [self checkLocationService];
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocation.latitude
                                                      longitude:self.currentLocation.longitude];
    NSDate *sometimeAgo = [[NSDate alloc]
                           initWithTimeIntervalSinceNow:-(60*60*hours)];
    
    PFQuery *query = [PFQuery queryWithClassName:@"CheckIn"];
    [query whereKey:@"checkinLocation" nearGeoPoint:userGeoPoint withinMiles:miles];
    [query whereKey:@"createdAt" greaterThan:sometimeAgo];
    [query addDescendingOrder:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopSpinnerForSender:sender];
        if(error){
            [self networkError];//  we just assume everything is network error...
        }else{
            [sender receivedCheckIns:objects];
        }
    }];

    
}

-(void)getNewsFeedFromSender:(id<AppModeDelegate>)sender
{
    [self startSpinnerForSender:sender];
    PFQuery *query = [PFQuery queryWithClassName:@"NewsFeed"];
    [query orderByDescending:@"createdAt"];
    [query addAscendingOrder:@"priority"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopSpinnerForSender:sender];
        if(error){
            [self networkError];//  we just assume everything is network error...
        }else{
            [sender receivedNewsFeed:objects];
        }
    }];
}

-(void)postNewsFeed:(NSString *)newsFeed fromPlayer:(NSString *)playerId withPlayerName:(NSString *)playerName withPriority:(int)priority
{
    PFObject *newsFeedObj = [PFObject objectWithClassName:@"NewsFeed"];
    [newsFeedObj setObject:newsFeed forKey:@"newsfeed"];
    [newsFeedObj setObject:playerId forKey:@"fromPlayerId"];
    [newsFeedObj setObject:playerName forKey:@"name"];
    [newsFeedObj setObject:[NSNumber numberWithInt:priority] forKey:@"priority"];
    [newsFeedObj saveEventually];
}

-(void)getPlayersForGame:(NSString *)gameId fromSender:(id<AppModeDelegate>)sender
{
    [self startSpinnerForSender:sender];
    PFQuery *query = [PFQuery queryWithClassName:@"GamePlayerRatings"];
    [query whereKey:@"gameId" equalTo:gameId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopSpinnerForSender:sender];
        if(error){
            [self networkError];//  we just assume everything is network error...
        }else{
            [sender receivedGamePlayers:objects];
        }
    }];
}


-(void)getGamesForUser:(NSString*)fbUserId fromSender:(id<AppModeDelegate>)sender
{
    [self startSpinnerForSender:sender];
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query whereKey:@"fbId" equalTo:fbUserId];
    [query addDescendingOrder:@"createdAt"];
    query.limit = 1000; // Let's hope we have to fix the limit soon!
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopSpinnerForSender:sender];
        if(error){
            [self networkError];//  we just assume everything is network error...
        }else{
            [sender receivedGames:objects];
        }
    }];
}

-(void)getCommentsForPlayer:(NSString*)fbUserId fromSender:(id<AppModeDelegate>)sender
{
    [self startSpinnerForSender:sender];
    PFQuery *query = [PFQuery queryWithClassName:@"GamePlayerRatings"];
    [query whereKey:@"toPlayerId" equalTo:fbUserId];
    [query addDescendingOrder:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopSpinnerForSender:sender];
        if(error){
            [self networkError];//  we just assume everything is network error...
        }else{
            if(objects && objects.count > 0){
                [sender receivedPlayerComments:objects];
            }
        }
    }];
    
}

// Must add to UserPointsA,userPointsB and PointHistory.
// This would actually mean 4 Parse accesses, so in the future we should
// fix this to use something like cloud code.
-(void)addPoints:(int) points toUser:(NSString *)fbUserId withCode:(NSString *)code
{
    // 1. Add points to class UserPointsA (Historical Accumulative)
    PFQuery *query = [PFQuery queryWithClassName:@"UserPointsA"];
    [query whereKey:@"fbUserId" equalTo:fbUserId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error){
            
        }else{
            if(objects && objects.count > 0){
                [self addUserPointsWithPoints:points forUser:fbUserId forPFObject:[objects objectAtIndex:0] updateRanking: NO];
            }else{
                [self addUserPointsWithPoints:points forUser:fbUserId forPFObject:[PFObject objectWithClassName:@"UserPointsA"] updateRanking:NO];
            }
        }
    }];
    
    
    // 2. Add points to class UserPointsB (Contest Accumulative)
    query = [PFQuery queryWithClassName:@"UserPointsB"];
    [query whereKey:@"fbUserId" equalTo:fbUserId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error){
            
        }else{
            if(objects && objects.count > 0){
                [self addUserPointsWithPoints:points forUser:fbUserId forPFObject:[objects objectAtIndex:0] updateRanking:YES];
            }else{
                [self addUserPointsWithPoints:points forUser:fbUserId forPFObject:[PFObject objectWithClassName:@"UserPointsB"] updateRanking:YES];
            }
        }
    }];
    
    // 3. Add points to UserPointsHistory (Complete history)
    PFObject *userPointsHistoroy = [PFObject objectWithClassName:@"UserPointsHistory"];
    [userPointsHistoroy setObject:fbUserId forKey:@"fbUserId"];
    [userPointsHistoroy setObject:[NSNumber numberWithInt:points] forKey:@"points"];
    [userPointsHistoroy setObject:code forKey:@"pointCode"];
    [userPointsHistoroy saveEventually];

}


-(void)addUserPointsWithPoints:(int) points forUser:(NSString *)fbUserId forPFObject:(PFObject *)userPointObj updateRanking:(BOOL)update
{
    [userPointObj setObject: fbUserId forKey:@"fbUserId"];
    [userPointObj incrementKey:@"points" byAmount:[NSNumber numberWithInt:points]];
    //[userPointObj saveEventually];
    [userPointObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            
        }else{
            // update ranking
            if(update)
                [self updateRankingForUser:fbUserId fromSender:nil];
        }
    }];
}

-(void)getCareerUserPointsForUser:(NSString*)fbUserId fromSender:(id<AppModeDelegate>)sender
{
    [self startSpinnerForSender:sender];
    PFQuery *query = [PFQuery queryWithClassName:@"UserPointsA"];
    [query whereKey:@"fbUserId" equalTo:fbUserId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopSpinnerForSender:sender];
        if(error){
            [self networkError];//  we just assume everything is network error...
        }else{
            if(objects.count>0){
                PFObject *obj = [objects objectAtIndex:0];
                if([sender respondsToSelector:@selector(careerPoints:forUser:)]){
                    [sender careerPoints:[obj objectForKey:@"points"] forUser:fbUserId];
                }
            }
        }
    }];
}

-(void)getSeasonUserPointsRankingForUser:(NSString*)fbUserId fromSender:(id<AppModeDelegate>)sender
{
    [self startSpinnerForSender:sender];
    PFQuery *query = [PFQuery queryWithClassName:@"UserPointsB"];
    [query whereKey:@"fbUserId" equalTo:fbUserId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopSpinnerForSender:sender];
        if(error){
            [self networkError];//  we just assume everything is network error...
        }else{
            if(objects.count>0){
                PFObject *obj = [objects objectAtIndex:0];
                if([sender respondsToSelector:@selector(seasonPoints:andRanking:forUser:)]){
                    [sender seasonPoints:[obj objectForKey:@"points"] andRanking:[obj objectForKey:@"ranking"] forUser:fbUserId];
                }
            }
        }
    }];
}

// usage of this method can be buggy in that when called upon after a user's point is
// updated, the other users' rankings are not updated.  Whenever a point is updated,
// all the other users' ranking may need to be updated...
-(void)updateRankingForUser:(NSString *)fbUserId fromSender:(id<AppModeDelegate>)sender
{
    [self startSpinnerForSender:sender];
    PFQuery *query = [PFQuery queryWithClassName:@"UserPointsB"]; // only rank season
    [query whereKey:@"fbUserId" equalTo:fbUserId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopSpinnerForSender:sender];
        if(error){
            [self networkError];//  we just assume everything is network error...
        }else{
            //1. get the current score
            if(objects.count > 0){
                PFObject *scoreObj = [objects objectAtIndex:0];
                NSNumber* userScore = [scoreObj objectForKey:@"points"];
                
                // 1.1 Also get the current ranking
                NSNumber* currentRanking = [scoreObj objectForKey:@"ranking"];
                
                //2. get number of people greater than user's score
                [self startSpinnerForSender:sender];
                PFQuery *q2 = [PFQuery queryWithClassName:@"UserPointsB"];
                [q2 whereKey:@"points" greaterThan:userScore];
                [q2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    [self stopSpinnerForSender:sender];
                    if(error){
                        
                    }else{
                        //3. increment the number by 1 and that is the user's ranking.
                        NSNumber *ranking = [NSNumber numberWithInt:objects.count + 1];
                        
                        //3.1 if ranking changed, update newsfeed
                        if([currentRanking intValue] != 0 && [currentRanking intValue] != [ranking intValue]){
                            // Get the user's name
                            
                            [self getNameForId:fbUserId withBlock:^(NSString *name) {
                               // Got the name!
                                NSString *news;
                                if([currentRanking intValue] > [ranking intValue]){
                                    // player moved up in ranking
                                    news = [NSString stringWithFormat:@"%@ moved up in ranking from %d to %d", name, currentRanking.intValue, ranking.intValue];
                                    // reward the user for moving up!
                                    [self kiipForUser:fbUserId withMessage:@"Moving upwards on the leaderboard!"];
                                   
                                }else if([currentRanking intValue] < [ranking intValue]){
                                    // player moved down in ranking
                                    news = [NSString stringWithFormat:@"%@ moved down in ranking from %d to %d", name, currentRanking.intValue, ranking.intValue];
                                }
                                
                                [self postNewsFeed:news fromPlayer:fbUserId withPlayerName:name withPriority:PRIORITY_MEDIUM];
                                
                            }];
                        }
                    
                        //4.1 save the ranking
                        [scoreObj setObject:ranking forKey:@"ranking"];
                        [scoreObj saveEventually];
                        if(sender && [sender respondsToSelector:@selector(rank:forUser:)]){
                            [sender rank:ranking forUser:fbUserId];
                        }
                        
                        //4.2 For convenience, also save in the Users table.
                        [self startSpinnerForSender:sender];
                        PFQuery *q3 = [PFQuery queryWithClassName:@"Users"];
                        [q3 whereKey:@"fbUserId" equalTo:fbUserId];
                        [q3 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                            [self stopSpinnerForSender:sender];
                            if(error){
                                
                            }else{
                                PFObject *userObj = [objects objectAtIndex:0];
                                [userObj setObject:ranking forKey:@"ranking"];
                                [userObj saveEventually];
                            }
                        }];
                        
                        
                        
                        
                    }
                    
                }];
            }

            
        }
    }];
}


-(void)addUser:(NSString*)fbUserId isApproved:(BOOL)approved byApprover:(NSString*)approverFbUserId fromSender:(id<AppModeDelegate>)sender
{
    [self startSpinnerForSender:sender];
    PFObject *user = [PFObject objectWithClassName:@"Users"];
    [user setObject:fbUserId forKey:@"fbUserId"];
    [user setObject:[NSNumber numberWithBool:approved] forKey:@"approved"];
    [user setObject:approverFbUserId forKey:@"approverFbUserId"];
    
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self stopSpinnerForSender:sender];
        if(!succeeded){ // saving failed
            //[sender userAddFailed:approverFbUserId];
            NSLog(@"Failed to add user");
        }else{
            [sender userAdded:approverFbUserId];
        }
    }];
}

-(void)checkUserQualification:(NSString *)userFbId fromSender:(id<AppModeDelegate>)sender
{
    
    // Go to FB and get the users' friends
    if(!CHECK_QUALIFICATION){
        [sender userQualifies:userFbId]; // no need to check.  directly qualifies.
        self.userApproved = YES;
    }else{
        if(FBSession.activeSession.isOpen)
        {
            NSString *query = @"SELECT friend_count FROM user WHERE uid = me()";
            NSDictionary *queryParam =
            [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
            [self startSpinnerForSender:sender];
            [FBRequestConnection startWithGraphPath:@"fql" parameters:queryParam HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                [self stopSpinnerForSender:sender];
                if(error){
                    // handle error
                }else{
                    id countObj = [[[result objectForKey:@"data"] objectAtIndex:0] objectForKey:@"friend_count"];
                    if([countObj isKindOfClass:[NSNumber class]]){
                        int count = [((NSNumber *)countObj) longValue];
                        if(count >= MIN_FRIEND_CRITERIA ){
                            self.userApproved = YES;
                            [sender userQualifies:userFbId];
                        }else{
                            self.userApproved = NO;
                            [sender userDoesNotQualify:userFbId];
                        }
                    }
                }
            }];
        }else{
            // Need to inform user an error occurred connecting to Facebook
        }
    }
}


-(void)checkUserExists:(NSString *)userFbId fromSender:(id<AppModeDelegate>)sender
{
    [self startSpinnerForSender:sender];
    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
    [query whereKey:@"fbUserId" equalTo:userFbId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopSpinnerForSender:sender];
        if(error){
           [self networkError];//  we just assume everything is network error... 
        }else{
            if(objects && objects.count > 0){
                self.userApproved = [[[objects objectAtIndex:0] objectForKey:@"approved"] boolValue];
                [sender userExists:userFbId];
            }else{
                [sender userDoesNotExist:userFbId];
            }
        }
    }];
}

-(void)didUserCheckIn:(id<AppModeDelegate>)sender
{
    [self startSpinnerForSender:sender];
    [self checkLocationService];
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocation.latitude
                                                      longitude:self.currentLocation.longitude];
    NSString *myFbUserId = [[self.myFbInfo objectForKey:@"id"] stringValue];
    
    NSTimeInterval hours = 60*60*CHECKIN_EXPIRATION;
    NSDate *hoursAgo = [[NSDate alloc]
                             initWithTimeIntervalSinceNow:-hours];
    
    
    // query checkin where fbUserId = me, within 1 mile of the location within last 3 hours
    PFQuery *query = [PFQuery queryWithClassName:@"CheckIn"];
    [query whereKey:@"checkinLocation" nearGeoPoint:userGeoPoint withinMiles:1.0];
    [query whereKey:@"fbUserId" equalTo:myFbUserId];
    [query whereKey:@"createdAt" greaterThan:hoursAgo];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopSpinnerForSender:sender];
        if(error){
            [self networkError];//  we just assume everything is network error...
        }else{
            if(objects && objects.count > 0){
                PFObject *pfobj = [objects objectAtIndex:0];
                _checkinInfo = [[NSMutableDictionary alloc] init];
                [_checkinInfo setValue:pfobj.objectId forKey:@"checkinId"];
                [_checkinInfo setValue:[pfobj objectForKey:@"venueId"] forKey:@"venueId"];
                [_checkinInfo setValue:[pfobj objectForKey:@"venueName"] forKey:@"venueName"];
                [sender userCheckedIn:self.checkinInfo];
            }else{
                [sender userDidNotCheckIn];
            }
        }
    }];
    
    
}

-(void)checkinForUser:(NSString *)fbUserId withMessage:(NSString*)msg atVenue:(NSString*)venueName withVenueId:(NSString*)venueId
{
    [self checkLocationService];
    PFObject *checkIn = [PFObject objectWithClassName:@"CheckIn"];
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.currentLocation.latitude longitude:self.currentLocation.longitude];
    [checkIn setObject:fbUserId forKey:@"fbUserId"];
    [checkIn setObject:msg forKey:@"checkinMessage"];
    [checkIn setObject:point forKey:@"checkinLocation"];
    [checkIn setObject:venueName forKey:@"venueName"];
    [checkIn setObject:venueId forKey:@"venueId"];
    
    [checkIn saveEventually];
}

-(void)allPlayers:(id<AppModeDelegate>)sender
{
    [self startSpinnerForSender:sender];
    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
    query.limit = 1000; // Let's hope we have to fix the limit soon!
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopSpinnerForSender:sender];
        if(error){
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self networkError];//  we just assume everything is network error...
        }else{
           
           NSMutableArray *returnArray = [[NSMutableArray alloc] init];
           for(PFObject *anObject in objects)
           {
               
               BOOL *isApproved = [[anObject objectForKey:@"approved"] boolValue];
               if(isApproved){
                   NSString *fbUserId = [anObject objectForKey:@"fbUserId"];
                   [returnArray addObject:fbUserId];
                   
                   // also, keep track of this player's ranking locally
                   NSNumber *ranking = [anObject objectForKey:@"ranking"];
                   if(ranking){
                       if(!self.rankingDic)
                           self.rankingDic = [[NSMutableDictionary alloc] init];
                       [self.rankingDic setObject:ranking forKey:fbUserId];
                   }
                   
               }
           }
           
            // Go to facebook!
            [self getFbProfileForAllPlayers:returnArray fromSender:sender];
           
        }
    }];
}

-(void)getRatingsForPlayer:(NSString*)fbId forSender:(id<AppModeDelegate>)sender
{
    [self startSpinnerForSender:sender];
    PFQuery *query = [PFQuery queryWithClassName:@"GamePlayerRatings"];
    [query whereKey:@"toPlayerId" equalTo:fbId];
    [query addDescendingOrder:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopSpinnerForSender:sender];
        if(error){
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self networkError];//  we just assume everything is network error...
        }else{
            // Array of Ratings
            float count = objects.count;
            float totalOffence = 0;
            float totalDefence = 0;
            float totalSportsmanship = 0;
            for(PFObject *object in objects){
                totalOffence += [[object objectForKey:@"offensiveRating"] floatValue];
                totalDefence += [[object objectForKey:@"defensiveRating"] floatValue];
                totalSportsmanship += [[object objectForKey:@"sportsmanshipRating"] floatValue];
            }
            if(count == 0)
                count++; // to avoid divide by 0
            float avgOffence = totalOffence / count;
            float avgDefence = totalDefence / count;
            float avgSportsmanship = totalSportsmanship / count;
            [sender avgRatingOffence:avgOffence andDefence:avgDefence andSportsmanship:avgSportsmanship withCount:objects.count];
            
        }
    }];
}

// all the players who checked in near me in the last 24 hours.
-(void)nearbyPlayers:(id<AppModeDelegate>)sender
{
    [self startSpinnerForSender:sender];
    [self checkLocationService];
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocation.latitude
                                                      longitude:self.currentLocation.longitude];
    
    NSTimeInterval hours = 60*60*SOMETIME_AGO;
    NSDate *sometimeAgo = [[NSDate alloc]
                             initWithTimeIntervalSinceNow:-hours];
    
    PFQuery *query = [PFQuery queryWithClassName:@"CheckIn"];
    [query whereKey:@"checkinLocation" nearGeoPoint:userGeoPoint withinMiles:NEARBY_RADIUS];
    [query whereKey:@"createdAt" greaterThan:sometimeAgo];
    [query addDescendingOrder:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopSpinnerForSender:sender];
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            if([sender respondsToSelector:@selector(receivedNearbyPlayers:)]){
                // Creating an array of dictionary to send back to caller
                NSMutableArray *returnArray = [[NSMutableArray alloc] init];
                NSMutableDictionary *checkDuplicateDictionary = [[NSMutableDictionary alloc] init];
                
                for(int i=0; i< objects.count; i++){
                    
                    PFObject *anObject = [objects objectAtIndex:i];
                    NSString *fbUserId = [anObject objectForKey:@"fbUserId"];
                    if(![checkDuplicateDictionary valueForKey:fbUserId]) // not a duplicate
                    {
                        // location
                        double lat = ((PFGeoPoint*)[anObject objectForKey:@"checkinLocation"]).latitude;
                        double ltd = ((PFGeoPoint*)[anObject objectForKey:@"checkinLocation"]).longitude;
                        CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:ltd];
                        
                        NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
                        [newDic setObject:loc forKey:@"checkinLocation"];
                        [newDic setObject:[anObject createdAt] forKey:@"createdAt"];
                        [newDic setObject:fbUserId forKey:@"fbUserId"];
                        [newDic setObject:[anObject objectForKey:@"checkinMessage"] forKey:@"checkinMessage"];
                        [newDic setObject:[anObject objectForKey:@"venueName"] forKey:@"venueName"];
                        [newDic setObject:[anObject objectForKey:@"venueId"] forKey:@"venueId"];
                        [checkDuplicateDictionary setObject:@"." forKey:fbUserId];
                        [returnArray addObject:newDic];
                    }

                }
                
                [sender receivedNearbyPlayers:returnArray];
            }
        }
    }];
}

-(void)saveGameWithId:(NSString*)gameId
           forCheckin:(NSString*)checkinId
              atVenue:(NSString*)venueId
         withVenuName:(NSString*)venueName
            forPlayer:(NSString*)fbId
              gameWon:(BOOL)gameW
{
    PFObject *aGame = [PFObject objectWithClassName:@"Games"];
    [aGame setObject:gameId forKey:@"gameId"];
    [aGame setObject:fbId forKey:@"fbId"];
    [aGame setObject:checkinId forKey:@"checkinId"];
    [aGame setObject:venueId forKey:@"venueId"];
    [aGame setObject:venueName forKey:@"venueName"];
    [aGame setObject:[NSNumber numberWithBool:gameW] forKey:@"gameWon"];
    [aGame saveEventually];
}

-(void)savePlayerRatingFromPlayer:(NSString*)fromPlayerId
                         toPlayer:(NSString*)toPlayerId
                          forGame:(NSString*)gameId
              withOffensiveRating:(int)offensiveRating
              withDefensiveRating:(int)defensiveRating
          withSportsmanshipRating:(int)sportsmanshipRating
                      withComment:(NSString *)comment
{
    PFObject *aRating = [PFObject objectWithClassName:@"GamePlayerRatings"];
    [aRating setObject:gameId forKey:@"gameId"];
    [aRating setObject:fromPlayerId forKey:@"fromPlayerId"];
    [aRating setObject:toPlayerId forKey:@"toPlayerId"];
    [aRating setObject:[NSNumber numberWithInt:offensiveRating] forKey:@"offensiveRating"];
    [aRating setObject:[NSNumber numberWithInt:defensiveRating] forKey:@"defensiveRating"];
    [aRating setObject:[NSNumber numberWithInt:sportsmanshipRating] forKey:@"sportsmanshipRating"];
    if(!comment)
        comment = @"";
    [aRating setObject:comment forKey:@"comment"];
    [aRating saveEventually];

}


//typedef void (^PFBooleanResultBlock)(BOOL succeeded, NSError *error);
//- (void)saveInBackgroundWithBlock:(PFBooleanResultBlock)block;
-(void)getNameForId:(NSString*)fbId withBlock:( void(^)(NSString *name) )codeBlock
{
    NSString *query = [NSString stringWithFormat:@"SELECT id, name, pic ,pic_square, pic_big, pic_small FROM profile where id = %@", fbId];
    NSDictionary *queryParam = [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
    
    
    [FBRequestConnection startWithGraphPath:@"fql" parameters:queryParam HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if(error){
            // handle error
            NSLog(@"getNameForId:withBlock: An error occured while talking to Facebook: %@", error);
        }else{
            NSString *playerNameFromFb = [[[result valueForKey:@"data"] objectAtIndex:0] objectForKey:@"name"];
            codeBlock(playerNameFromFb);

        }
    }];
}

#pragma mark - Facebook Methods

// called interally by allPlayers: players is an array of NSDictionary
-(void)getFbProfileForAllPlayers:(NSArray*)players fromSender:(id<AppModeDelegate>)sender
{
    //if(FBSession.activeSession.isOpen)
    //{
        [self startSpinnerForSender:sender];
        NSString * playerFbIds = @"(";
        if( players.count > 0){
            for(int i=0; i < players.count; i++){
                NSString *fbUserId = [players objectAtIndex:i];
                playerFbIds = [playerFbIds stringByAppendingString:fbUserId];
                
                if(i < players.count - 1){
                    playerFbIds = [playerFbIds stringByAppendingString:@", "];
                }
            }
        }
        playerFbIds = [playerFbIds stringByAppendingString:@")"];
        
        NSString *query = [NSString stringWithFormat:@"SELECT id, name, pic ,pic_square, pic_big, pic_small FROM profile where id in %@", playerFbIds];
        NSDictionary *queryParam = [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
        
        [FBRequestConnection startWithGraphPath:@"fql" parameters:queryParam HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            [self stopSpinnerForSender:sender];
            if(error){
                // handle error
                NSLog(@"An error occured while talking to Facebook: %@", error);
            }else{
                if([sender respondsToSelector:@selector(receivedAllPlayerFbProfiles:)]){
                    [sender receivedAllPlayerFbProfiles:[result valueForKey:@"data"]];
                }
            }
        }];
    //}
}

// used to be get nearby players, but later on shared to be used to get any array of players.
// players is array of PFObjects
-(void)getFbProfilesForPlayers:(NSArray*)players useKeyName:(NSString*)keyName fromSender:(id<AppModeDelegate>) sender
{
    //if(FBSession.activeSession.isOpen)
    //{
        [self startSpinnerForSender:sender];
        NSString * playerFbIds = @"(";
        if( players.count > 0){
            for(int i=0; i < players.count; i++){
                NSString *fbUserId = [((PFObject *)[players objectAtIndex:i]) objectForKey:keyName];
                
                playerFbIds = [playerFbIds stringByAppendingString:fbUserId];
                
                if(i < players.count - 1){
                    playerFbIds = [playerFbIds stringByAppendingString:@", "];
                }
            }
        }
        playerFbIds = [playerFbIds stringByAppendingString:@")"];
        

        NSString *query = [NSString stringWithFormat:@"SELECT id, name, pic ,pic_square, pic_big, pic_small FROM profile where id in %@", playerFbIds];
        NSDictionary *queryParam = [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
        
        [FBRequestConnection startWithGraphPath:@"fql" parameters:queryParam HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            [self stopSpinnerForSender:sender];
            if(error){
                // handle error
                NSLog(@"An error occured while talking to Facebook: %@", error);
            }else{
                if([sender respondsToSelector:@selector(receivedPlayerFbProfiles:)]){
                    [sender receivedPlayerFbProfiles:[result valueForKey:@"data"]];
                }
            }
        }];
    //}
}

NSString *const FBInfoReturnedNotification = @"com.eugenicode.SecondRound:FBInfoReturnedNotification";
// TODO: Store my FB info on device.
-(void)getMyFbInfo
{
    if(FBSession.activeSession.isOpen)
    {
        NSString *query = @"SELECT id, name, pic_square, pic_big, pic FROM profile where id = me()";
        NSDictionary *queryParam =
        [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
        
        [FBRequestConnection startWithGraphPath:@"fql" parameters:queryParam HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if(error){
                // handle error
                
            }else{

                _myFbInfo = [[result objectForKey:@"data"] objectAtIndex: 0];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:FBInfoReturnedNotification
                 object:self.myFbInfo];
                
                
            }
        }];
    }
}



#pragma mark - Location Manager Methods
NSString *const SignificantLocationChageNotification = @"com.eugenicode.SecondRound:SignificantLocationChangeNotification";
NSString *const FoursquareVenueUpdated = @"com.eugenicode.SecondRound:FoursquareVenueUpdateNotification";

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"User Location Updated: %f, %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
    _currentLocation = self.locationManager.location.coordinate;
    
    // Contact Foursquare to update venues
    [self getVenuesFromFourSquare];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:SignificantLocationChageNotification
     object:manager];
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([[error domain] isEqualToString: kCLErrorDomain] && [error code] == kCLErrorDenied) {
        // The user denied your app access to location information.
        NSLog(@"Error: User denied app for location service");
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorized:
            NSLog(@"location service authorization switched to AUTHORIZED");
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"location service authorization switched to DENIED");
            break;
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"location service authorization switched to UNDETERINED");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"location service authorization switched to RESTRICTED");
        default:
            break;
    }
}


#pragma mark - Internal Private Methods
-(void)activateOutstandingKiip
{
    PFQuery *query = [PFQuery queryWithClassName:@"Kiip"];
    NSString *myFbId = [[self.myFbInfo objectForKey:@"id"] stringValue];
    if(myFbId){
        [query whereKey:@"fbUserId" equalTo:[[self.myFbInfo objectForKey:@"id"] stringValue]];
        [query whereKey:@"activated" equalTo:[NSNumber numberWithBool:NO]];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(error){
                
            }else{
                if(objects && objects.count == 0){
                    // we do nothing.
                }else{
                    PFObject *kiipObj = [objects objectAtIndex:0];
                    NSString *message = [kiipObj valueForKey:@"message"];
                    [[Kiip sharedInstance] saveMoment:message withCompletionHandler:nil];
                    [kiipObj setObject:[NSNumber numberWithBool:YES] forKey:@"activated"];
                    [kiipObj saveEventually];
                }
            }
        }];
    }
    
}

-(void)kiipForUser:(NSString*)fbUserId withMessage:(NSString*)message
{
    //if user already has an unactivated reward, then we don't do anything.
    //if fbUserId is the app user, immediate activate Kiip. Otherwise just save it to Parse.
    PFQuery *query = [PFQuery queryWithClassName:@"Kiip"];
    [query whereKey:@"fbUserId" equalTo:fbUserId];
    [query whereKey:@"activated" equalTo:[NSNumber numberWithBool:NO]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error){
            
        }else{
            if(objects && objects.count > 0){
                // we do nothing.
            }else{
                bool activated = NO;
                if([fbUserId isEqualToString:[[self.myFbInfo objectForKey:@"id"] stringValue]]){
                    // activate Kiip
                    [[Kiip sharedInstance] saveMoment:message withCompletionHandler:nil];
                    activated = YES;
                }
                // save to Parse
                PFObject *kiipObj = [PFObject objectWithClassName:@"Kiip"];
                [kiipObj setObject:fbUserId forKey:@"fbUserId"];
                [kiipObj setObject:message forKey:@"message"];
                [kiipObj setObject:[NSNumber numberWithBool:activated] forKey:@"activated"];
                [kiipObj saveEventually];
            }
        }
    }];
    
    
}


#pragma mark - Helper Methods
- (void)startSignificantChangeUpdates
{
    // Create the location manager if this object does not
    // already have one.
    NSLog(@"Starting significant change updates...");
    if (nil == self.locationManager)
        self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    bool enabled = [CLLocationManager locationServicesEnabled];
    if(enabled)
        [self.locationManager startMonitoringSignificantLocationChanges];
}

-(void)networkError
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                        message:NETWORK_ERROR
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)checkLocationService
{
    // check if we have access to location service
    bool locationServiceEnabled = [CLLocationManager locationServicesEnabled];
    CLAuthorizationStatus locationServiceStatus = [CLLocationManager authorizationStatus];
    
    if (!locationServiceEnabled)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NO_LOCATION_SERVICE_ALERT_TITLE
                                                            message:NO_LOCATION_SERVICE_ALERT_SYSTEM_MESSAGE
                                                           delegate:self
                                                  cancelButtonTitle:NO_LOCATION_SERVICE_ALERT_CANCEL_BUTTON_TITLE
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
    else if (locationServiceStatus != kCLAuthorizationStatusAuthorized)
    {
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NO_LOCATION_SERVICE_ALERT_TITLE
                                                            message:NO_LOCATION_SERVICE_ALERT_MESSAGE
                                                           delegate:self
                                                  cancelButtonTitle:NO_LOCATION_SERVICE_ALERT_CANCEL_BUTTON_TITLE
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}


#pragma mark - Initialization Methods
- (id)init
{
	self = [super init];
	if (self != nil) {
        [self startSignificantChangeUpdates];
	}
    
    // TESTING
    //PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    //[testObject setObject:@"bar" forKey:@"foo"];
    //[testObject save];
    
	return self;
}

+ (id)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

// Pre-condition: already have current location.
-(void)getVenuesFromFourSquare
{
    [self checkLocationService];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    NSString *strUrl = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%f,%f&client_id=%@&client_secret=%@&v=%@",self.currentLocation.latitude, self.currentLocation.longitude, FOURSQUARE_CLIENT_ID, FOURSQUARE_CLIENT_SECRET, [dateFormatter stringFromDate:[NSDate date]]];
    
    NSURL *url = [NSURL URLWithString:strUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if([JSON isKindOfClass:[NSDictionary class]]){
            _nearbyVenues = [JSON valueForKeyPath:@"response.venues"];
             
            [[NSNotificationCenter defaultCenter]
             postNotificationName:FoursquareVenueUpdated
             object:nil];
            
        }
    } failure:nil];
    
    [operation start];
}

-(void)dealWithError:(NSError *)error forSender:(id<AppModeDelegate>) sender
{
    
}

-(void)startSpinnerForSender:(id<AppModeDelegate>) sender
{
    if([sender respondsToSelector:@selector(startSpinner)])
    {
        [sender startSpinner];
    }
        
}

-(void)stopSpinnerForSender:(id<AppModeDelegate>) sender
{
    if([sender respondsToSelector:@selector(stopSpinner)])
    {
        [sender stopSpinner];
    }
}


@end

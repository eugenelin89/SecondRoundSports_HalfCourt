//
//  AppModel.h
//  Caribbean
//
//  Created by Eugene Lin on 13-01-23.
//  Copyright (c) 2013 Eugene Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define PRIORITY_HIGHEST 1
#define PRIORITY_MEDIUM 50
#define PRIORITY_LOWEST 99
#define NEARBY_RADIUS 5.0 // 100
#define SOMETIME_AGO 12 //8760//12 // in hours
#define CHECKIN_EXPIRATION 3 // in hours


@protocol AppModeDelegate <NSObject>
@optional
-(void)receivedNearbyPlayers:(NSArray*)players;
-(void)receivedAllPlayerFbProfiles:(NSArray *)fbPlayerProfiles;
-(void)receivedPlayerFbProfiles:(NSArray*)playerFbProfiles;
-(void)userCheckedIn:(NSDictionary *)checkinInfo;
-(void)userDidNotCheckIn;
-(void)userExists:(NSString*)userFbId;
-(void)userDoesNotExist:(NSString*)userFbId;
-(void)userQualifies:(NSString*)userFbId;
-(void)userDoesNotQualify:(NSString*)userFbId;
-(void)userAdded:(NSString *)userFbId;
-(void)userAddFailed:(NSString *)userFbId;
-(void)avgRatingOffence:(float)offensiveRating andDefence:(float)defensiveRating andSportsmanship:(float)sportsmanshipRating withCount:(int)count;
-(void)rank:(NSNumber*)rank forUser:(NSString*)fbUserId;
-(void)seasonPoints:(NSNumber*)points andRanking:(NSNumber*)ranking forUser:(NSString*)fbUserId;
-(void)careerPoints:(NSNumber*)points forUser:(NSString*)fbUserId;
-(void)receivedPlayerComments:(NSArray *)comments;
-(void)receivedGames:(NSArray *)games;
-(void)receivedGamePlayers:(NSArray *)players;
-(void)startSpinner;
-(void)stopSpinner;
-(void)receivedNewsFeed:(NSArray *)newsFeed;
-(void)receivedCheckIns:(NSArray *)checkIns;

@end

@interface AppModel : NSObject
extern NSString *const SignificantLocationChageNotification;
extern NSString *const FoursquareVenueUpdated;
extern NSString *const FBInfoReturnedNotification;
@property (readonly, nonatomic) CLLocationCoordinate2D currentLocation;
@property (strong, readonly, nonatomic) NSArray *nearbyVenues;
@property (strong, readonly, nonatomic) NSDictionary *myFbInfo;
@property (strong, readonly, nonatomic) NSDictionary *checkinInfo; // valid after calling didUserCheckIn with affirmative result
@property (nonatomic) BOOL userApproved;


#pragma mark - Configuration Parameters from Database
@property (nonatomic) BOOL configCheckCriteria;
@property (nonatomic) BOOL configRunContest;
@property (nonatomic, strong) NSString* configContestName;
@property (strong, nonatomic) NSMutableDictionary *rankingDic; // key = fbId, value = ranking

@property (nonatomic) bool mapToCheckin; // if YES, we show checkin view in map view directly.



+ (id)sharedInstance;
-(void)getMyFbInfo;
-(void)checkinForUser:(NSString *)fbUserId withMessage:(NSString*)msg atVenue:(NSString*)venueName withVenueId:(NSString*)venueId;
-(void)nearbyPlayers:(id<AppModeDelegate>)sender;
-(void)allPlayers:(id<AppModeDelegate>)sender;
-(void)getFbProfileForAllPlayers:(NSArray*)players fromSender:(id<AppModeDelegate>)sender;
-(void)getFbProfilesForPlayers:(NSArray*)players useKeyName:(NSString*)keyName fromSender:(id<AppModeDelegate>) sender;
-(void)didUserCheckIn:(id<AppModeDelegate>)sender;
-(void)saveGameWithId:(NSString*)gameId
           forCheckin:(NSString*)checkinId
              atVenue:(NSString*)venueId
         withVenuName:(NSString*)venueName
            forPlayer:(NSString*)fbId
              gameWon:(BOOL)gameW;
-(void)savePlayerRatingFromPlayer:(NSString*)fromPlayerId
                         toPlayer:(NSString*)toPlayerId
                          forGame:(NSString*)gameId
              withOffensiveRating:(int)offensiveRating
              withDefensiveRating:(int)defensiveRating
          withSportsmanshipRating:(int)sportsmanshipRating
                      withComment:(NSString *)comment;
-(void)checkUserExists:(NSString *)userFbId fromSender:(id<AppModeDelegate>)sender;
-(void)checkUserQualification:(NSString *)userFbId fromSender:(id<AppModeDelegate>)sender;
-(void)addUser:(NSString*)fbUserId isApproved:(BOOL)approved byApprover:(NSString*)approverFbUserId fromSender:(id<AppModeDelegate>)sender;
-(void)addPoints:(int) points toUser:(NSString *)fbUserId withCode:(NSString *)code;
-(void)getRatingsForPlayer:(NSString*)fbId forSender:(id<AppModeDelegate>)sender;
-(void)updateRankingForUser:(NSString *)fbUserId fromSender:(id<AppModeDelegate>)sender;
-(void)getSeasonUserPointsRankingForUser:(NSString*)fbUserId fromSender:(id<AppModeDelegate>)sender;
-(void)getCareerUserPointsForUser:(NSString*)fbUserId fromSender:(id<AppModeDelegate>)sender;
-(void)getCommentsForPlayer:(NSString*)fbUserId fromSender:(id<AppModeDelegate>)sender;
-(void)getGamesForUser:(NSString*)fbUserId fromSender:(id<AppModeDelegate>)sender;
-(void)getPlayersForGame:(NSString *)gameId fromSender:(id<AppModeDelegate>)sender;
-(void)postNewsFeed:(NSString *)newsFeed fromPlayer:(NSString *)playerId withPlayerName:(NSString *)playerName withPriority:(int)priority;
-(void)getNewsFeedFromSender:(id<AppModeDelegate>)sender;
-(void)getCheckinWithinRadius:(double)miles withinHours:(int)hours fromSender:(id<AppModeDelegate>)sender;
-(void)activateOutstandingKiip;

@end

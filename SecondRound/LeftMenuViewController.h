//
//  LeftMenuViewController.h
//  Second Date
//
//  Created by Eugene Lin on 13-04-11.
//  Copyright (c) 2013 Second Date. All rights reserved.
//
#import <UIKit/UIKit.h>

// Total Number of Sections in Menu Table
#define SECTIONS 1

// Section 0 -  Main
#define SECTION0_TITLE @"Second Round"
#define SECTION0_ROWS 5

#define NEWS_FEED @"News Feed"
#define NEWS_FEED_SUB @""

#define ME @"Me"
#define ME_SUB @""

#define MAP @"Map"
#define MAP_SUB @"Checkin and find others"

#define GAMES @"My Games"
#define GAMES_SUB @"Add/View game results"

#define PLAYERS @"Leaderboard"
#define PLAYERS_SUB @""

#define SIGNOUT @"Sign Out"
#define SIGNOUT_SUB @""

#define SETTINGS @"Settings"
#define SETTINGS_SUB @""

#define SECTION0_ROW0 PLAYERS //NEWS_FEED
#define SECTION0_ROW0_SUB PLAYERS_SUB

#define SECTION0_ROW1 GAMES//PLAYERS //MAP
#define SECTION0_ROW1_SUB GAMES_SUB

#define SECTION0_ROW2 MAP //GAMES
#define SECTION0_ROW2_SUB MAP_SUB

#define SECTION0_ROW3 NEWS_FEED //GAMES// ME
#define SECTION0_ROW3_SUB NEWS_FEED_SUB

#define SECTION0_ROW4 SIGNOUT
#define SECTION0_ROW4_SUB SIGNOUT_SUB
//#define SECTION0_ROW5 SETTINGS

// Section 1 - My Ladders
#define SECTION1_TITLE @"My Ladders"

// Section 2 - My Challenges
#define SECTION2_TITLE @"My Challenges"

// View IDs
#define MAP_VIEW_ID @"MAP_VIEW"
#define NEWS_FEED_VIEW_ID @"NEWS_FEED"
#define GAME_VIEW_ID @"GAME_VIEW"
#define PLAYER_VIEW_ID @"PLAYER_VIEW"

@protocol LeftMenuControllerDelegate <NSObject>

-(void) switchToViewWithId:(NSString*)viewId;

@end

@interface LeftMenuViewController : UIViewController
@property (weak, nonatomic) id<LeftMenuControllerDelegate> delegate;

@end

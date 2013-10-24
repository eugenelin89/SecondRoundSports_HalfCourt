//
//  AppDelegate.h
//  SecondRound
//
//  Created by Eugene Lin on 13-04-16.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

//TODO: Work on login.  When user first use the system, we record the user.
//If the user satisfies certain criteria (such as number of FB friends), we mark the user
//as valid.  Otherwise, we mark the user as pending. If the user is valid, we give access immediately.
//In the future as user tries to login, we need to check the users table.  If don't exist, it's
//first time user.  If exist, we give acccess only if user is valid.  This way, we can control
//user access


#import <UIKit/UIKit.h>
#import <KiipSDK/KiipSDK.h>
#import "IIViewDeckController.h"

#define PARSE_APP_ID @"YOUR PARSE APP ID"
#define PARSE_CLIENT_KEY @"YOUR PARSE CLIENT KEY"
#define FOURSQUARE_CLIENT_ID @"YOUR FOURSQUARE CLIENT ID"
#define FOURSQUARE_CLIENT_SECRET @"YOUR FOURSQUARE CLIENT SECRET"
#define KIIP_APP_KEY @"YOUR KIIP APP KEY"
#define KIIP_APP_SECRET @"YOUR KIIP APP SECRET"

#define CHECK_QUALIFICATION 0

#define DEFAULT_RED 0.60
#define DEFAULT_GREEN 0.96
#define DEFAULT_BLUE 1.0
#define DEFAULT_ALPHA 1.0
// Deep Sky Blue
#define SECOND_RED 0.0
#define SECOND_GREEN 0.75
#define SECOND_BLUE 1.0
#define SECOND_ALPHA 1.0

#define DEFAULT_PLAYER_RATING_COMMENT @"Some comments?"
#define DEFAULT_CHECKIN_MESSAGE @"Powered by Foursquare"
#define PLEASE_CHECKIN @"Please go to Map to checkin before adding new game."
#define NETWORK_ERROR @"The Internet connection appears to be offline."
#define NO_LOCATION_SERVICE_ALERT_TITLE @"Location Service Unavailable"
#define NO_LOCATION_SERVICE_ALERT_MESSAGE @"Go to Settings -> Privacy -> Location Services to enable service for Half Court."
#define NO_LOCATION_SERVICE_ALERT_SYSTEM_MESSAGE @"Device does not support location service"
#define NO_LOCATION_SERVICE_ALERT_CANCEL_BUTTON_TITLE @"OK"


#define MIN_FRIEND_CRITERIA 50

#define POINTS_CHECKIN 1
#define POINTS_RATING 1
#define POINTS_WIN 1

#define CODE_CHECKIN @"CHECKIN"
#define CODE_RATING  @"RATE"
#define CODE_SKILLS @"SKILL"
#define CODE_WIN @"WIN"

#define LOGIN_TIMEOUT 7.0
#define PRIVACY_URL @"http://www.secondroundsports.com/app/privacy.html"

@interface AppDelegate : UIResponder <UIApplicationDelegate, KiipDelegate>

@property (strong, nonatomic) UIWindow *window;

#pragma mark - Facebook
extern NSString *const FBSessionStateChangedNotification;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void)closeSession;

@end

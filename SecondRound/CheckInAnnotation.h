//
//  CheckInAnnotation.h
//  SecondRound
//
//  Created by Eugene Lin on 13-08-15.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface CheckInAnnotation : NSObject<MKAnnotation>

@property (strong, nonatomic) NSDictionary* venue;
+(CheckInAnnotation*)annotationForCheckin:(NSDictionary*)venue;

@end

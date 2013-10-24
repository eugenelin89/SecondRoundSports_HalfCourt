//
//  CheckInAnnotation.m
//  SecondRound
//
//  Created by Eugene Lin on 13-08-15.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "CheckInAnnotation.h"

@implementation CheckInAnnotation
@synthesize venue = _venue;

+(CheckInAnnotation *)annotationForCheckin:(NSDictionary *)venue
{
    CheckInAnnotation *anno = [[CheckInAnnotation alloc] init];
    anno.venue = venue;
    return anno;
}


-(NSString *)title
{
    return [self.venue objectForKey:@"venueName"];
}

-(NSString*)subtitle
{
    int numPlayers = ((NSArray*)[self.venue objectForKey:@"players"]).count;
    NSString *subTitle = [NSString stringWithFormat:@"%d players", numPlayers];
    return subTitle;
}

-(CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = ((PFGeoPoint*)[self.venue objectForKey:@"checkinLocation"]).latitude;
    coordinate.longitude = ((PFGeoPoint*)[self.venue objectForKey:@"checkinLocation"]).longitude;
    return coordinate;
}

@end

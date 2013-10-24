//
//  MapViewController.h
//  SecondRound
//
//  Created by Eugene Lin on 13-06-06.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMemberViewController.h"

@interface MapViewController : BaseMemberViewController
@property (nonatomic, strong) NSArray *annotations;  // of id<MKAnnotation>
@end

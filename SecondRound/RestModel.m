//
//  RestModel.m
//  SecondRound
//
//  Created by Eugene Lin on 13-05-25.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "RestModel.h"
#import "AFJSONRequestOperation.h"

#define SERVER_URL @"peaceful-refuge-4858.herokuapp.com/v1"


@implementation RestModel


+ (id)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(NSDictionary *)getUserFor:(NSString*)userFbId
                       with:(NSString*)accessToken
                    success:(void(^)())success
                    failure:(void(^)())failure
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/User/%@", SERVER_URL, userFbId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:userFbId forHTTPHeaderField:@"id"];
    [request addValue:accessToken forHTTPHeaderField:@"token"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        

        
        
    } failure: ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        NSLog(@"Fail, JSON: %@", JSON);

    }];
    
    [operation start];
    
    
    return nil;
    
}

@end

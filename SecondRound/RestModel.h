//
//  RestModel.h
//  SecondRound
//
//  Created by Eugene Lin on 13-05-25.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//
//  Singleton Class.  Use +(id)sharedInstance to access object.


#import <Foundation/Foundation.h>

@interface RestModel : NSObject
+ (id)sharedInstance;


/*
 
 + (instancetype)JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest
 success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
 failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
 */

-(NSDictionary *)getUserFor:(NSString*)userFbId
             with:(NSString*)accessToken
          success:(void(^)())success
              failure:(void(^)())failure;



@end

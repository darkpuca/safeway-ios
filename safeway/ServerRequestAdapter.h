//
//  ServerRequestAdapter.h
//  safeway
//
//  Created by darkpuca on 2014. 3. 25..
//  Copyright (c) 2014년 Kim Dongkyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface ServerRequestAdapter : NSObject

+ (void)requestPhoneNumberAuthorization:(NSString *)phoneNumber
                                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (void)requestAuthorizeNumberConfirm:(NSString *)phoneNumber
                      authorizeNumber:(NSString *)authorizeNumber
                              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


@end

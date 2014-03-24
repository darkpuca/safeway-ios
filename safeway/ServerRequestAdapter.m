//
//  ServerRequestAdapter.m
//  safeway
//
//  Created by darkpuca on 2014. 3. 25..
//  Copyright (c) 2014년 Kim Dongkyu. All rights reserved.
//

#import <SVProgressHUD.h>
#import <RaptureXML/RXMLElement.h>

#import "ServerRequestAdapter.h"

#define phone_number_authorize_url      @"http://210.107.227.23/_app/send_auth_sms.php"
#define authorize_confirm_url           @"http://210.107.227.23/_app/do_check_auth_no.php"


@implementation ServerRequestAdapter

+ (void)requestPhoneNumberAuthorization:(NSString *)phoneNumber
                                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    if (nil == phoneNumber || 0 == [phoneNumber length]) return;

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = responseSerializer;

    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:1];
    [params setValue:phoneNumber forKey:@"telno"];

    [manager POST:phone_number_authorize_url parameters:params success:success failure:failure];
}

+ (void)requestAuthorizeNumberConfirm:(NSString *)phoneNumber authorizeNumber:(NSString *)authorizeNumber success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = responseSerializer;

    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    [params setValue:phoneNumber forKey:@"telno"];
    [params setValue:authorizeNumber forKey:@"authno"];

    [manager POST:authorize_confirm_url parameters:params success:success failure:failure];
}

@end

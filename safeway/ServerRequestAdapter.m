//
//  ServerRequestAdapter.m
//  safeway
//
//  Created by darkpuca on 2014. 3. 25..
//  Copyright (c) 2014년 Kim Dongkyu. All rights reserved.
//

#import <RaptureXML/RXMLElement.h>

#import "ServerRequestAdapter.h"

NSString *PHONE_NUMBER_AUTHORIZE_URL =  @"http://darc1004.com/_app/send_auth_sms.php";
NSString *AUTHORIZE_CONFIRM_URL =       @"http://darc1004.com/_app/do_check_auth_no.php";
NSString *GET_MESSAGES_URL =            @"http://darc1004.com/_app/get_messages.php";
NSString *DEVICE_REGISTRATION_URL =     @"http://darc1004.com/_app/do_regist_user.php";
NSString *UPDATE_LAST_INDEX_URL =       @"http://darc1004.com/_app/do_update_smslogidx.php";



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

    NSLog(@"request url:\n%@\nparams:\n%@\n", PHONE_NUMBER_AUTHORIZE_URL, params);

    [manager POST:PHONE_NUMBER_AUTHORIZE_URL parameters:params success:success failure:failure];
}

+ (void)requestAuthorizeNumberConfirm:(NSString *)phoneNumber authorizeNumber:(NSString *)authorizeNumber success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = responseSerializer;

    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    [params setValue:phoneNumber forKey:@"telno"];
    [params setValue:authorizeNumber forKey:@"authno"];

    NSLog(@"request url:\n%@\nparams:\n%@\n", AUTHORIZE_CONFIRM_URL, params);

    [manager POST:AUTHORIZE_CONFIRM_URL parameters:params success:success failure:failure];
}

+ (void)requestRegistDeviceToken:(NSString *)phoneNumber token:(NSString *)token success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = responseSerializer;

    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    [params setValue:phoneNumber forKey:@"telno"];
    [params setValue:token forKey:@"uid"];
    [params setValue:@"I" forKey:@"type"];

    NSLog(@"request url:\n%@\nparams:\n%@\n", DEVICE_REGISTRATION_URL, params);

    [manager POST:DEVICE_REGISTRATION_URL parameters:params success:success failure:failure];
}

+ (void)requestMessages:(NSString *)token phoneNumber:(NSString *)phoneNumber success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = responseSerializer;

    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:1];
    [params setValue:phoneNumber forKey:@"telno"];
    [params setValue:token forKey:@"uid"];

    NSLog(@"request url:\n%@\nparams:\n%@\n", GET_MESSAGES_URL, params);

    [manager POST:GET_MESSAGES_URL parameters:params success:success failure:failure];
}

+ (void)requestUpdateLastMessageIndex:(NSString *)token phoneNumber:(NSString *)phoneNumber index:(NSInteger)index success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = responseSerializer;

    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    [params setValue:phoneNumber forKey:@"telno"];
    [params setValue:token forKey:@"uid"];
    [params setValue:[NSNumber numberWithInteger:index] forKey:@"smslogidx"];

    NSLog(@"request url:\n%@\nparams:\n%@\n", UPDATE_LAST_INDEX_URL, params);

    [manager POST:UPDATE_LAST_INDEX_URL parameters:params success:success failure:failure];
}


+ (NSDictionary *)parseResponse:(NSData *)responseData
{
    NSMutableDictionary *responseDict = [[NSMutableDictionary alloc] init];

    NSString *responseXml = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"response xml: \n%@", responseXml);

    RXMLElement *resultElmt = [RXMLElement elementFromXMLData:responseData];
    if (nil == resultElmt) return nil;

    RXMLElement *codeElmt = [resultElmt child:@"code"];
    if (nil != codeElmt) [responseDict setValue:[NSNumber numberWithInteger:[codeElmt textAsInt]] forKey:@"code"];

    RXMLElement *messageElmt = [resultElmt child:@"message"];
    if (nil != messageElmt) [responseDict setValue:[messageElmt text] forKey:@"message"];

    RXMLElement *reasonElmt = [resultElmt child:@"reason"];
    if (nil != reasonElmt) [responseDict setValue:[reasonElmt text] forKey:@"reason"];

    RXMLElement *mtypeElmt = [resultElmt child:@"mtype"];
    if (nil != mtypeElmt) [responseDict setValue:[mtypeElmt text] forKey:@"mtype"];

    NSArray *items = [resultElmt children:@"item"];
    if (0 < [items count])
    {
        NSMutableArray *messages = [[NSMutableArray alloc] init];

        for (RXMLElement *oneElmt in items)
        {
            NSMutableDictionary *messageDict = [[NSMutableDictionary alloc] init];

            RXMLElement *senderElmt = [oneElmt child:@"sender"];
            if (nil != senderElmt) [messageDict setValue:[senderElmt text] forKey:@"sender_number"];

            RXMLElement *msgElmt = [oneElmt child:@"msg"];
            if (nil != msgElmt) [messageDict setValue:[msgElmt text] forKey:@"message"];

            RXMLElement *logidxElmt = [oneElmt child:@"logidx"];
            if (nil != logidxElmt) [messageDict setValue:[NSNumber numberWithInteger:[logidxElmt textAsInt]] forKey:@"index"];

            RXMLElement *sendtimeElmt = [oneElmt child:@"sendtime"];
            if (nil != sendtimeElmt)
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [messageDict setValue:[dateFormatter dateFromString:sendtimeElmt.text] forKey:@"send_time"];
            }
            
            [messages addObject:messageDict];
        }

        [responseDict setValue:messages forKey:@"messages"];
    }

    return responseDict;
}

@end

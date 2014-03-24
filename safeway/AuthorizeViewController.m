//
//  AuthorizeViewController.m
//  safeway
//
//  Created by darkpuca on 2014. 3. 23..
//  Copyright (c) 2014년 Kim Dongkyu. All rights reserved.
//

#import "AuthorizeViewController.h"
#import "Globals.h"
#import "AppDelegate.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import <RaptureXML/RXMLElement.h>

#import "ServerRequestAdapter.h"

@interface AuthorizeViewController ()

@property (nonatomic, strong) NSString *phoneNumber, *authNumber, *deviceToken, *userType;

@end

@implementation AuthorizeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.phoneNumberField becomeFirstResponder];

    [self.authNumberField setEnabled:NO];
    [self.confirmButton setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Functions

- (IBAction)authRequestPressed:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (NO == appDelegate.pushAvailable)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"푸시 서비스가 불가능한 기기입니다. 인증을 진행할 수 없습니다."
                                                           delegate:nil
                                                  cancelButtonTitle:@"닫기"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _deviceToken = [userDefaults valueForKey:@"device_token"];

    NSString *phoneNumber = self.phoneNumberField.text;
    _phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];

    if (0 == _phoneNumber.length)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"휴대전호 번호를 입력해 주십시요."
                                                           delegate:nil
                                                  cancelButtonTitle:@"닫기"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }

    [SVProgressHUD showWithStatus:@"인증 번호를 요청중입니다."];

    [ServerRequestAdapter requestPhoneNumberAuthorization:_phoneNumber
                                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                      [SVProgressHUD dismiss];

                                                      RXMLElement *resultElmt = [RXMLElement elementFromXMLData:responseObject];
                                                      RXMLElement *messageElmt = [resultElmt child:@"message"];
                                                      NSString *message = messageElmt.text;

                                                      // 정상적으로 수신한 경우 처리
                                                      if ([message isEqualToString:@"done"])
                                                      {
                                                          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                                                              message:@"인증 번호가 발송되었습니다. 전송된 인증번호를 입력해 주십시요."
                                                                                                             delegate:nil cancelButtonTitle:@"닫기"
                                                                                                    otherButtonTitles:nil];
                                                          [alertView show];

                                                          [self.phoneNumberField setEnabled:NO];
                                                          [self.requestButton setEnabled:NO];
                                                          [self.authNumberField setEnabled:YES];
                                                          [self.confirmButton setEnabled:YES];
                                                          [self.authNumberField becomeFirstResponder];
                                                      }
                                                      else
                                                      {
                                                          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                                                              message:@"인증 번호를 요청할 수 없습니다. 잠시후 다시 시도해 주십시요."
                                                                                                             delegate:nil cancelButtonTitle:@"닫기"
                                                                                                    otherButtonTitles:nil];
                                                          [alertView show];
                                                      }
                                                  }
                                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                      [SVProgressHUD dismiss];
                                                      NSLog(@"Error: %@", error);
                                                  }];
}

- (IBAction)authConfirmPressed:(id)sender
{
    NSString *authNumber = self.authNumberField.text;
    _authNumber = [authNumber stringByReplacingOccurrencesOfString:@" " withString:@""];

    if (0 == _authNumber.length)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"인증 번호를 입력해 주십시요."
                                                           delegate:nil
                                                  cancelButtonTitle:@"닫기"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }

    [SVProgressHUD showWithStatus:@"인증 번호를 확인중입니다."];

    [ServerRequestAdapter requestAuthorizeNumberConfirm:_phoneNumber
                                        authorizeNumber:_authNumber
                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                    [SVProgressHUD dismiss];

                                                    NSString *responseXml = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                                    NSLog(@"response xml: %@", responseXml);

                                                    RXMLElement *resultElmt = [RXMLElement elementFromXMLData:responseObject];
                                                    RXMLElement *codeElmt = [resultElmt child:@"code"];
                                                    NSInteger code = [codeElmt.text integerValue];

                                                    // 정상적으로 수신한 경우 처리
                                                    if (0 == code)
                                                    {
                                                        RXMLElement *mtypeElmt = [resultElmt child:@"mtype"];
                                                        _userType = mtypeElmt.text;

                                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                                                            message:@"인증이 완료되었습니다."
                                                                                                           delegate:self
                                                                                                  cancelButtonTitle:@"닫기"
                                                                                                  otherButtonTitles:nil];
                                                        alertView.tag = 100;
                                                        [alertView show];
                                                    }
                                                    else
                                                    {
                                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                                                            message:@"인증이 실패하였습니다. 다시 시도해 주십시요."
                                                                                                           delegate:nil cancelButtonTitle:@"닫기"
                                                                                                  otherButtonTitles:nil];
                                                        [alertView show];
                                                    }
                                                }
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    [SVProgressHUD dismiss];
                                                    NSLog(@"Error: %@", error);
                                                }];
}


#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (100 == alertView.tag && 0 == buttonIndex)
    {
        // device token 정보 전송
        [SVProgressHUD showWithStatus:@"푸시 서비스를 위한 정보를 등록중입니다."];

        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer = responseSerializer;

        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
        [params setValue:_phoneNumber forKey:@"telno"];
        [params setValue:_deviceToken forKey:@"uid"];
        [params setValue:@"I" forKey:@"type"];

        [manager POST:DEVICE_REGISTRATION_URL parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject){
                  [SVProgressHUD dismiss];

                  NSString *responseXml = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                  NSLog(@"response xml: %@", responseXml);

                  RXMLElement *resultElmt = [RXMLElement elementFromXMLData:responseObject];
                  RXMLElement *codeElmt = [resultElmt child:@"code"];

                  NSInteger code = [codeElmt.text integerValue];

                  // 정상적으로 수신한 경우 처리
                  if (0 == code || 1 == code)
                  {
                      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                          message:@"푸시 서비스 정보가 등록되었습니다."
                                                                         delegate:self
                                                                cancelButtonTitle:@"닫기"
                                                                otherButtonTitles:nil];
                      alertView.tag = 200;
                      [alertView show];
                  }
                  else
                  {
                      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                          message:@"푸시 서비스 정보 등록을 실패했습니다."
                                                                         delegate:nil cancelButtonTitle:@"닫기"
                                                                otherButtonTitles:nil];
                      [alertView show];
                  }
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [SVProgressHUD dismiss];
                  NSLog(@"Error: %@", error);
              }];

    }
    else if (200 == alertView.tag && 0 == buttonIndex)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:_phoneNumber forKey:@"phone_number"];
        [userDefaults setValue:_userType forKey:@"user_type"];
        [userDefaults setBool:YES forKey:@"is_authorized"];
        [userDefaults synchronize];

        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


@end

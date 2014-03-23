//
//  AuthorizeViewController.h
//  safeway
//
//  Created by darkpuca on 2014. 3. 23..
//  Copyright (c) 2014년 Kim Dongkyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthorizeViewController : UIViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField, *authNumberField;
@property (weak, nonatomic) IBOutlet UIButton *requestButton, *confirmButton;

- (IBAction)authRequestPressed:(id)sender;
- (IBAction)authConfirmPressed:(id)sender;

@end

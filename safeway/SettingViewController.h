//
//  SettingViewController.h
//  safeway
//
//  Created by darkpuca on 2014. 5. 18..
//  Copyright (c) 2014년 Kim Dongkyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *versionLabel;

- (IBAction)messageClearButtonPressed:(id)sender;

@end

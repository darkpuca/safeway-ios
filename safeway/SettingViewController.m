//
//  SettingViewController.m
//  safeway
//
//  Created by darkpuca on 2014. 5. 18..
//  Copyright (c) 2014년 Kim Dongkyu. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"

@interface SettingViewController ()


@end

@implementation SettingViewController

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

    [self updateVersionInformation];
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

- (IBAction)messageClearButtonPressed:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고"
                                                        message:@"모든 수신 메세지가 삭제됩니다. 계속 하시겠습니까?"
                                                       delegate:self
                                              cancelButtonTitle:@"취소"
                                              otherButtonTitles:@"계속", nil];
    [alertView show];
}

- (void)updateVersionInformation
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *labelString = [NSString stringWithFormat:@"디아크 등교천사 버전 %@", version];
    [_versionLabel setText:labelString];
}

- (void)clearAllMessages
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    // clear messages from CoreData
    NSLog(@"clear all messages");
    NSManagedObjectContext * context = [appDelegate managedObjectContext];

    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context]];

    NSArray * result = [context executeFetchRequest:fetch error:nil];

    for (id message in result)
        [context deleteObject:message];
}


#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex)
    {
        [self clearAllMessages];
    }
}


@end

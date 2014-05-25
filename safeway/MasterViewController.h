//
//  MasterViewController.h
//  safeway
//
//  Created by darkpuca on 2014. 3. 15..
//  Copyright (c) 2014년 Kim Dongkyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)updateMessages;
- (void)playNotiSound;


@end

//
//  MasterViewController.m
//  safeway
//
//  Created by darkpuca on 2014. 3. 15..
//  Copyright (c) 2014년 Kim Dongkyu. All rights reserved.
//
#import <SVProgressHUD.h>
#import <RaptureXML/RXMLElement.h>

#import "MasterViewController.h"
#import "AuthorizeViewController.h"
#import "ServerRequestAdapter.h"
#import "AppDelegate.h"

static const CGFloat messageCellHeight = 72.0f;
static const CGFloat messageLabelWidth = 260.0f;
static const CGFloat messageLabelFontSize = 14.0f;

@interface MasterViewController ()

@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, assign) BOOL newMessageExist;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)insertMessages:(NSArray *)messages;
- (void)updateLastIndex:(NSInteger)index;
- (void)scrollToLastMessage:(BOOL)animated;


@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//  self.navigationItem.leftBarButtonItem = self.editButtonItem;

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;

    [self.tableView setRowHeight:messageCellHeight];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isAuthorized = [userDefaults boolForKey:@"is_authorized"];

    if (NO == isAuthorized)
    {
        // 인증이 안된 기기일 경우 인증 화면으로 이동
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AuthorizeViewController *authorizedViewController = [storyboard instantiateViewControllerWithIdentifier:@"AuthorizeViewController"];
        [self presentViewController:authorizedViewController animated:YES completion:nil];
    }
    else
    {
        // 정상 인증된 기기이면 메세지 리스트 정보 갱신
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _deviceToken = [userDefaults valueForKey:@"device_token"];

        // clear core data
//        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//        [appDelegate clearCoreData];
        [self updateMessages];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    return;

    // add sample message
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"send_time"];
    [newManagedObject setValue:@"test message" forKey:@"message"];
    [newManagedObject setValue:@"010-9023-1518" forKey:@"sender_number"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error])
    {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    NSString *messageString = [object valueForKey:@"message"];
//    CGSize maximumSize = CGSizeMake(messageLabelWidth, 1000.0f);
//    CGSize messageSize = [messageString sizeWithFont:[UIFont systemFontOfSize:messageLabelFontSize]
//                                   constrainedToSize:maximumSize
//                                       lineBreakMode:NSLineBreakByWordWrapping];
//
//    CGFloat modSize = messageSize.height - 44.0f;
//    if (modSize < 0.0f)
//        modSize = 0.0f;
//
//    return 74.0f + modSize;
    return messageCellHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> theSection = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSString *section_name = [theSection name];
    return section_name;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSLog(@"sel message: %@", [object valueForKey:@"message"]);
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"section_name" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"send_time" ascending:YES];

    NSArray *sortDescriptors = @[sortDescriptor1, sortDescriptor2];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"section_name" cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UILabel *dateLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *messageLabel = (UILabel *)[cell viewWithTag:102];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"a h:mm"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *timeString = [formatter stringFromDate:[object valueForKey:@"send_time"]];
    NSString *messageString = [object valueForKey:@"message"];

    [dateLabel setText:timeString];

    CGRect messageRect = messageLabel.frame;

    CGSize maximumSize = CGSizeMake(messageRect.size.width, 9999);
    CGSize messageSize = [messageString sizeWithFont:messageLabel.font
                                   constrainedToSize:maximumSize
                                       lineBreakMode:messageLabel.lineBreakMode];
    messageRect.size.height = messageSize.height;
    [messageLabel setFrame:messageRect];
    [messageLabel setText:messageString];
}


#pragma mark - Functions

- (void)insertMessages:(NSArray *)messages
{
    if (nil == messages) return;

    for (NSDictionary *messageDict in messages)
    {
        NSInteger messageId = [messageDict[@"index"] integerValue];
        if (YES == [self isExistMessage:messageId]) continue;

        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];

        NSDate *sendTime = messageDict[@"send_time"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        NSString *sectionName = [formatter stringFromDate:sendTime];

        [newManagedObject setValue:sectionName forKey:@"section_name"];
        [newManagedObject setValue:messageDict[@"index"] forKey:@"index"];
        [newManagedObject setValue:messageDict[@"message"] forKey:@"message"];
        [newManagedObject setValue:messageDict[@"send_time"] forKey:@"send_time"];
        [newManagedObject setValue:messageDict[@"sender_number"] forKey:@"sender_number"];

        // Save the context.
        NSError *error = nil;
        if (![context save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

- (BOOL)isExistMessage:(NSInteger)messageId
{
    NSString *predicateString = [NSString stringWithFormat:@"index == %d", messageId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

	NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (nil != results && 0 < [results count])
        return YES;

    return NO;
}

- (void)updateMessages
{
    [SVProgressHUD show];

    [ServerRequestAdapter requestMessages:_deviceToken
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      BOOL added = NO;
                                      NSDictionary *responseDict = [ServerRequestAdapter parseResponse:responseObject];
                                      if (1 == [responseDict[@"code"] integerValue])
                                      {
                                          NSArray *messages = responseDict[@"messages"];
                                          [self insertMessages:messages];

                                          NSDictionary *lastMessage = [messages lastObject];
                                          [self updateLastIndex:[lastMessage[@"index"] integerValue]];

                                          added = YES;
                                      }
                                      else
                                      {
                                          // test proc
//                                          [self updateLastIndex:100];
                                      }

                                      [self.tableView reloadData];
                                      [SVProgressHUD dismiss];

                                      [self scrollToLastMessage:added];
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                      [SVProgressHUD dismiss];
                                      NSLog(@"Error: %@", error);
                                  }];

}

- (void)updateLastIndex:(NSInteger)index
{
    [ServerRequestAdapter requestUpdateLastMessageIndex:_deviceToken
                                                  index:index
                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {

                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                                                }];
}

- (void)scrollToLastMessage:(BOOL)animated
{
    id lastObject = [[self.fetchedResultsController fetchedObjects] lastObject];
    NSIndexPath *lastIndexPath = [self.fetchedResultsController indexPathForObject:lastObject];

    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

@end

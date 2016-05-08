//
//  HighScoreViewController.m
//  Card Match
//
//  Created by Quentin Lin on 6/05/2016.
//  Copyright © 2016 coder9t99. All rights reserved.
//

#import "HighScoreViewController.h"
#import "AppDelegate.h"
#import "HighScoreSynchroniser.h"
#import "HighScoreViewCell.h"
#import <CoreData/NSEntityDescription.h>

NSString * const kHighScoreCellId = @"HighScoreCellId";

@interface HighScoreViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (readonly) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)configureCell:(HighScoreViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)reloadData:(id)reloadData;
@end

@implementation HighScoreViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (NSManagedObjectContext*)managedObjectContext {
    AppDelegate *appDelegate = UIApplication.sharedApplication.delegate;
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    return context;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Score"
                                        inManagedObjectContext:self.managedObjectContext]];

    [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO]]];
    [fetchRequest setFetchBatchSize:20];

    NSFetchedResultsController *theFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;

    return _fetchedResultsController;
}

- (void)configureCell:(HighScoreViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *scoreObject = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.rank = @(indexPath.row + 1);
    cell.name = [scoreObject valueForKey:@"name"];
    cell.score = [scoreObject valueForKey:@"score"];
}

- (void)reloadData:(id)reloadData {
    [self.tableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData:)
                                                 name:kDataSyncComplete
                                               object:nil];

    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }

    UINib *cellNib = [UINib nibWithNibName:@"HighScoreViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kHighScoreCellId];

    self.title = @"Failed Banks";
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[(NSUInteger)section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HighScoreViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHighScoreCellId forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
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

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}
@end

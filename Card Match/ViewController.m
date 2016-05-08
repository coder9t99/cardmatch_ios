//
//  ViewController.m
//  Card Match
//
//  Created by Quentin Lin on 5/05/2016.
//  Copyright © 2016 coder9t99. All rights reserved.
//

#import "ViewController.h"

#import "AppDelegate.h"
#import "CardMatch.h"
#import "CardViewCell.h"
#import "IIViewDeckController.h"
#import "NSString+isEmptyOrWhiteSpace.h"

NSString * const kCardCellReuseId = @"CardCell";
const NSUInteger kGridSize = 4;

@interface ViewController () <UICollectionViewDataSource, UIScrollViewDelegate, CardMatchDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *selectedCardIndices;
@property (nonatomic, strong) CardMatch *cardMatch;

- (void)restartGame;
- (void)match;
- (BOOL)flip:(NSIndexPath*)indexPath;

- (void)deselectCards;
- (void)removeSelectedCards;
- (void)resetAll;
- (void)saveScore:(NSInteger)score withName:(NSString*)name;

@end

@implementation ViewController

- (void)restartGame {
    [self.cardMatch start];
    [self resetAll];
}

- (void)match {
    NSAssert(self.selectedCardIndices.count >= 2, @"Must select two cards in order to match cards");

    NSNumber *selection1 = self.selectedCardIndices[0];
    NSNumber *selection2 = self.selectedCardIndices[1];

    BOOL hasMatch = [self.cardMatch match:selection1.unsignedIntegerValue with:selection2.unsignedIntegerValue];

    [self performSelector:hasMatch
                         ?@selector(removeSelectedCards)
                         :@selector(deselectCards)
               withObject:nil
               afterDelay:1.5];

    self.navigationItem.title = [NSString stringWithFormat:@"%ld", (long)self.cardMatch.currentScore];
}

- (BOOL)flip:(NSIndexPath *)indexPath {
    CardViewCell *cell = (CardViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return [cell flip];
}

- (void)deselectCards {
    while (self.selectedCardIndices.count) {
        NSNumber *selectedIndex = self.selectedCardIndices.lastObject;
        [self flip:[NSIndexPath indexPathForRow:selectedIndex.unsignedIntegerValue inSection:0]];
        [self.selectedCardIndices removeLastObject];
    }
}

- (void)removeSelectedCards {
    while (self.selectedCardIndices.count) {
        NSNumber *selectedIndex = self.selectedCardIndices.lastObject;
        CardViewCell *cell = (CardViewCell*)
            [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex.unsignedIntegerValue
                                                                           inSection:0]];
        [cell remove];
        [self.selectedCardIndices removeLastObject];
    }
}

- (void)resetAll {
    for (NSUInteger i = 0; i < kGridSize * kGridSize; i++) {
        CardViewCell *cell =
            (CardViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];

        [cell reset];
    }
    [self.collectionView reloadData];

    self.navigationItem.title = [NSString stringWithFormat:@"%ld", (long)self.cardMatch.currentScore];
}


- (void)saveScore:(NSInteger)score withName:(NSString *)name {
    AppDelegate *appDelegate = UIApplication.sharedApplication.delegate;

    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Score" inManagedObjectContext:context];

    NSManagedObject *scoreObject = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
    [scoreObject setValue:@(score) forKey:@"score"];
    [scoreObject setValue:name forKey:@"name"];
    [scoreObject setValue:@(0) forKey:@"batch_tag"];

    NSError *error;
    [context save:&error]; // error is ignored for this excercise...

    if (error) {
        NSLog(@"Unable to save score %ld for %@.", (long)score, name);
    }

    // sync
    [appDelegate.synchroniser sync];
}


- (void)setupNavigationItems {
    // Logo
    UIImage *logoImage = [UIImage imageNamed:@"logo"];
    UIButton *logoButton = [[UIButton alloc] init];
    CGFloat barHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat resizeRatio = (barHeight - 8.f) /logoImage.size.height;
    logoButton.frame = CGRectMake(0.f, 0.f, logoImage.size.width * resizeRatio, logoImage.size.height * resizeRatio);
    [logoButton setImage:logoImage forState:UIControlStateNormal];
    [logoButton addTarget:self.viewDeckController
                   action:@selector(toggleLeftView)
         forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logoButton];

    // Highscore button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"High Score"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self.viewDeckController
                                                                             action:@selector(toggleRightView)];
    // Current Score
    self.navigationItem.title = @"0";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationItems];
    [self.collectionView registerClass:CardViewCell.class forCellWithReuseIdentifier:kCardCellReuseId];
    self.cardMatch = CardMatch.new;
    self.cardMatch.delegate = self;
    self.selectedCardIndices = NSMutableArray.new;
}

-(void)viewDidLayoutSubviews {
    static const CGFloat margin = 10.f;

    static const CGFloat numberOfColumns = kGridSize;
    static const CGFloat numberOfRows    = kGridSize;

    static const CGFloat totalColumnMargins
        = margin // left
        + margin // right
        + (margin * (numberOfRows - 1.f)); // between columns

    CGSize  contentSize = self.collectionView.frame.size;
    CGFloat actualTopBottomMargin = contentSize.height * .1f;

    CGFloat totalRowMargins
        = actualTopBottomMargin // top
        + actualTopBottomMargin // bottom
        + (margin * (numberOfRows - 1.f)); // between rows

    CGFloat cellWidth   = (contentSize.width  - totalColumnMargins) / numberOfColumns;
    CGFloat cellHeight  = (contentSize.height - totalRowMargins   ) / numberOfRows;

    UICollectionViewFlowLayout *collectionLayout = UICollectionViewFlowLayout.new;

    collectionLayout.itemSize     = CGSizeMake(cellWidth, cellHeight);
    collectionLayout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);

    self.collectionView.collectionViewLayout = collectionLayout;
    self.collectionView.contentInset = UIEdgeInsetsMake(actualTopBottomMargin - margin, 0.f, actualTopBottomMargin - margin, 0.f);
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kGridSize * kGridSize;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CardViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCardCellReuseId
                                                                   forIndexPath:indexPath];
    cell.faceId = self.cardMatch.cardData[(NSUInteger)indexPath.row];
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedCardIndices.count >= 2) {
        return;
    }

    NSNumber *rowNumber = @(indexPath.row);
    if ([self.selectedCardIndices containsObject:rowNumber]) {
        // NOTE: card already selected. do nothing.
        // NOTE: should flip back be allowed, this is probably ideal place to modify
        //[self.selectedCardIndices removeObject:rowNumber];
    } else {
        [self flip:indexPath];
        [self.selectedCardIndices addObject:rowNumber];
    }

    if (self.selectedCardIndices.count >= 2) {
        [self match];
    }
}

#pragma mark - UIScrollViewDelegate

-(void)gameOver:(NSInteger)score {
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"You've Done It!"
                                            message:@"Please enter your name"
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Please enter your name";
    }];

    UIAlertAction *submitAction = [UIAlertAction actionWithTitle:@"Submit"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action){
                                                             UITextField *textField = alertController.textFields.firstObject;
                                                             [self saveScore:score withName:textField.text];
                                                             [self restartGame];
                                                         }];

    submitAction.enabled = false;
    [alertController addAction:submitAction];

// SKIP button is disabled
//    UIAlertAction *skipAction = [UIAlertAction actionWithTitle:@"Skip"
//                                                           style:UIAlertActionStyleCancel
//                                                         handler:^(UIAlertAction *action){ [self restartGame]; }];
//    [alertController addAction:skipAction];

    // Notifications for textFieldName changes
    [NSNotificationCenter.defaultCenter addObserverForName:UITextFieldTextDidChangeNotification
                                                    object:alertController.textFields[0]
                                                     queue:NSOperationQueue.mainQueue
                                                usingBlock:^(NSNotification *note) {
                                                    UITextField *textField = alertController.textFields.firstObject;
                                                    submitAction.enabled = !textField.text.isEmptyOrWhiteSpace;
                                                }];


    [self presentViewController:alertController animated:YES completion:nil];
}
@end

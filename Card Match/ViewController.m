//
//  ViewController.m
//  Card Match
//
//  Created by Quentin Lin on 5/05/2016.
//  Copyright © 2016 Accedo. All rights reserved.
//

#import "ViewController.h"
#import "CardViewCell.h"
#import "IIViewDeckController.h"

NSString * const kCardCellReuseId = @"CardCell";
const NSUInteger kGridSize = 4;

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *selectedCardIndices;
@property (nonatomic, strong) CardMatch *cardMatch;

- (void)restartGame;
- (void)match;
- (BOOL)flip:(NSIndexPath*)indexPath;

- (void)deselectCards;
- (void)removeSelectedCards;
- (void)resetAll;

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

- (void)setupNavigationItems {
    // Logo
    UIImage *logoImage = [UIImage imageNamed:@"logo"];
    UIButton *logoButton = [[UIButton alloc] init];
    CGFloat barHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat resizeRatio = (barHeight - 8.f) /logoImage.size.height;
    logoButton.frame = CGRectMake(0.f, 0.f, logoImage.size.width * resizeRatio, logoImage.size.height * resizeRatio);
    [logoButton setImage:logoImage forState:UIControlStateNormal];
    [logoButton addTarget:self.viewDeckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
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
    self.collectionView.contentInset = UIEdgeInsetsMake(actualTopBottomMargin, 0.f, actualTopBottomMargin, 0.f);
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kGridSize * kGridSize;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CardViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCardCellReuseId forIndexPath:indexPath];
    cell.faceId = self.cardMatch.cardData[(NSUInteger)indexPath.row];
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedCardIndices.count >= 2) {
        return;
    }

    if ([self flip:indexPath]) {
        [self.selectedCardIndices addObject:@(indexPath.row)];
    }

    if (self.selectedCardIndices.count >= 2) {
        [self match];
    }
}

#pragma mark - UIScrollViewDelegate

-(void)gameOver:(NSInteger)score {
    [self performSelector:@selector(restartGame) withObject:nil afterDelay:2];
}
@end

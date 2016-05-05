//
//  ViewController.m
//  Card Match
//
//  Created by Quentin Lin on 5/05/2016.
//  Copyright © 2016 Accedo. All rights reserved.
//

#import "ViewController.h"
#import "CardViewCell.h"

NSString * const kCardCellReuseId = @"CardCell";
const NSUInteger kGridSize = 4;
NSUInteger const cardData[kGridSize * kGridSize] =
    {
        1, 1,
        2, 2,
        3, 3,
        4, 4,
        5, 5,
        6, 6,
        7, 7,
        8, 8,
    };

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *selectedCardIndices;

- (void)match;
- (BOOL)flip:(NSIndexPath*)indexPath;
- (void)remove:(NSIndexPath*)indexPath;

- (void)deselectCards;
- (void)removeSelectedCards;

@end

@implementation ViewController

- (void)match {
    NSAssert(self.selectedCardIndices.count >= 2, @"Must select two cards in order to match cards");

    NSNumber *selection1 = self.selectedCardIndices[0];
    NSNumber *selection2 = self.selectedCardIndices[1];

    NSUInteger cardId1 = cardData[selection1.integerValue];
    NSUInteger cardId2 = cardData[selection2.integerValue];

    // TODO: move logic away
    BOOL hasMatch = cardId1 == cardId2;

    [self performSelector:hasMatch
                         ?@selector(removeSelectedCards)
                         :@selector(deselectCards)
               withObject:nil
               afterDelay:1.5];
}

- (BOOL)flip:(NSIndexPath *)indexPath {
    CardViewCell *cell = (CardViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return [cell flip];
}

- (void)remove:(NSIndexPath *)indexPath {
    CardViewCell *cell = (CardViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell remove];
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
        [self remove:[NSIndexPath indexPathForRow:selectedIndex.unsignedIntegerValue inSection:0]];
        [self.selectedCardIndices removeLastObject];
    }
}

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedCardIndices = NSMutableArray.new;
    [self.collectionView registerClass:CardViewCell.class forCellWithReuseIdentifier:kCardCellReuseId];
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
    cell.faceId = cardData[indexPath.row];
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

@end

//
// Created by Quentin Lin on 6/05/2016.
// Copyright (c) 2016 coder9t99. All rights reserved.
//

#import "CardMatch.h"
#import "NSMutableArray+Shuffle.h"

const NSInteger defaultScore = 2;
const NSInteger penalty = -1;

NSUInteger cardDataTemplate[16] =
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

@interface CardMatch ()

@property NSUInteger pairsRemaining;

- (void)gameOver;
- (void)matchFound;
- (void)matchNotFound;
@end


@implementation CardMatch

- (instancetype)init{
    self = super.init;
    if (self) {
        [self start];
    }
    return self;
}

- (void)start {
    NSMutableArray *cardData = NSMutableArray.new;
    for (NSUInteger i = 0; i < self.totalCardCount; i++) {
        [cardData addObject:@(cardDataTemplate[i])];
    }
    [cardData shuffle];
    _cardData = cardData;
    self.currentScore = 0;
    self.pairsRemaining = (self.totalCardCount) / 2;
}

- (BOOL)match:(NSUInteger)cardPos1 with:(NSUInteger)cardPos2
{
    NSNumber *cardId1 = self.cardData[cardPos1];
    NSNumber *cardId2 = self.cardData[cardPos2];

    BOOL hasMatch = cardId1 == cardId2;

    if (!hasMatch) {
        [self matchNotFound];
    } else {
        [self matchFound];
        self.pairsRemaining --;

        if (self.noMorePairToMatch) {
            [self gameOver];
        }
    }

    return hasMatch;
}

- (NSUInteger)gridSize {
    return 4;
}

- (NSUInteger)totalCardCount {
    return 16;
}

- (BOOL)noMorePairToMatch {
    return self.pairsRemaining == 0;
}

- (void)gameOver {
    if (self.delegate && [self.delegate respondsToSelector:@selector(gameOver:)]) {
        [self.delegate gameOver:self.currentScore];
    }
}

- (void)matchFound {
    self.currentScore += defaultScore;
}

- (void)matchNotFound {
    self.currentScore += penalty;
}

@end

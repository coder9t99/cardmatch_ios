//
//  Card_MatchTests.m
//  Card MatchTests
//
//  Created by Quentin Lin on 5/05/2016.
//  Copyright © 2016 coder9t99. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CardMatch.h"

@interface Card_MatchTests : XCTestCase
@property (nonatomic, strong) CardMatch *cardMatch;
@end

#pragma mark - helper classes definitions
@interface CardMatchDelegateTester : NSObject<CardMatchDelegate>
@property BOOL triggered;
@end


#pragma mark - test body
@implementation Card_MatchTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.cardMatch = CardMatch.new;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.cardMatch = nil;
}

- (void)testRestartGameWillShuffleCardData {
    NSArray<NSNumber*> *cardDataBeforeRestart = [self.cardMatch.cardData copy];
    [self.cardMatch start];
    NSArray<NSNumber*> *cardDataAfterRestart = self.cardMatch.cardData;

    BOOL isCardDataSame = YES;
    for (NSUInteger i = 0; i < cardDataBeforeRestart.count; i++) {
        NSNumber *cardNumber1 = cardDataBeforeRestart[i];
        NSNumber *cardNumber2 = cardDataAfterRestart[i];
        if (![cardNumber1 isEqualToNumber:cardNumber2]) {
            isCardDataSame = NO;
            break;
        }
    }

    XCTAssertFalse(isCardDataSame, @"card data before and after `start` should be different.");
}

- (void)testCorrectMatchWillAddTwoPoints {
    NSNumber *targetNumber = @(1);
    NSMutableArray<NSNumber*> *positions = [NSMutableArray arrayWithCapacity:2];
    for (NSUInteger i = 0; i < self.cardMatch.totalCardCount; i++) {
        if ([targetNumber isEqualToNumber:self.cardMatch.cardData[i]]) {
            [positions addObject:@(i)];
        }
    }
    [self.cardMatch match:positions[0].unsignedIntegerValue with:positions[1].unsignedIntegerValue];

    XCTAssertEqual(self.cardMatch.currentScore, 2, @"correct match should result +2 points");
}

- (void)testIncorrectMatchWillReduceONePoint {
    NSUInteger pos1 = 0;
    NSUInteger pos2 = 0;
    NSNumber *targetNumber = self.cardMatch.cardData[pos1];
    for (NSUInteger i = 1; i < self.cardMatch.totalCardCount; i++) {
        if (![targetNumber isEqualToNumber:self.cardMatch.cardData[i]]) {
            pos2 = i;
        }
    }
    [self.cardMatch match:pos1 with:pos2];

    XCTAssertEqual(self.cardMatch.currentScore, -1, @"correct match should result -1 points");
}

- (void)testWhenAllCardMatchedWillTriggerGameOver {
    CardMatchDelegateTester *delegateTester = CardMatchDelegateTester.new;
    self.cardMatch.delegate = delegateTester;

    // match all
    for (NSUInteger target = 0; target < self.cardMatch.totalCardCount / 2; target++) {
        NSNumber *targetNumber = @(target+1);
        NSMutableArray<NSNumber*> *positions = [NSMutableArray arrayWithCapacity:2];
        for (NSUInteger i = 0; i < self.cardMatch.totalCardCount; i++) {
            if ([targetNumber isEqualToNumber:self.cardMatch.cardData[i]]) {
                [positions addObject:@(i)];
            }
        }
        [self.cardMatch match:positions[0].unsignedIntegerValue with:positions[1].unsignedIntegerValue];
    }

    XCTAssertTrue(delegateTester.triggered, @"when all card matched `gameOver:` should be triggered.");
}

@end

#pragma mark - helper classes implementations
@implementation CardMatchDelegateTester

-(instancetype)init {
    self = super.init;
    if (self) {
        self.triggered = NO;
    }
    return self;
}

-(void)gameOver:(NSInteger)score
{
    self.triggered = YES;
}
@end

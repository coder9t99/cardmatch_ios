//
// Created by Quentin Lin on 6/05/2016.
// Copyright (c) 2016 coder9t99. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CardMatchDelegate<NSObject>
@optional
-(void)gameOver:(NSInteger)score;
@end


@interface CardMatch : NSObject

@property (nonatomic, weak) id<CardMatchDelegate> delegate;
@property (readonly) NSUInteger gridSize;
@property (readonly) NSUInteger totalCardCount;
@property (readonly) BOOL noMorePairToMatch;
@property (readonly) NSArray<NSNumber*> *cardData;
@property NSInteger currentScore;

- (void)start;
- (BOOL)match:(NSUInteger)cardPos1 with:(NSUInteger)cardPos2;
@end
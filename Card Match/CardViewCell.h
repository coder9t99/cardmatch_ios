//
//  CardViewCell.h
//  Card Match
//
//  Created by Quentin Lin on 5/05/2016.
//  Copyright © 2016 Accedo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CardState) {
    CardFaceUp = 1,
    CardFaceDown,
    CardRemoved,
};

@interface CardViewCell : UICollectionViewCell

@property (readonly) CardState cardState;
@property (nonatomic, strong) NSNumber *faceId;

-(BOOL)flip;
-(void)remove;
-(void)reset;

+(NSTimeInterval)animationDuration;

@end

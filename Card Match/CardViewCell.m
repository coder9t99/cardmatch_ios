//
//  CardViewCell.m
//  Card Match
//
//  Created by Quentin Lin on 5/05/2016.
//  Copyright © 2016 Accedo. All rights reserved.
//

#import "CardViewCell.h"

NSString * const kCardFaceImagePrefix = @"colour";

@interface CardViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;

@end

@implementation CardViewCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *nibs = [NSBundle.mainBundle loadNibNamed:@"CardViewCell" owner:self options:nil];

        self = nibs.count > 0
            && [nibs[0] isKindOfClass:CardViewCell.class]
             ? nibs[0]
             : nil;
    }
    return self;
}

- (BOOL)flip {
    if (_cardState == CardRemoved) {
        return NO;
    }

    _cardState = self.faceImageView.hidden ? CardFaceUp : CardFaceDown;
    [UIView transitionWithView:self.contentView
                      duration:CardViewCell.animationDuration
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        self.faceImageView.hidden = !self.faceImageView.hidden;
                        self.backImageView.hidden = !self.backImageView.hidden;
                    }
                    completion:nil];
    return YES;
}

- (void)remove {
    [UIView transitionWithView:self.contentView
                      duration:CardViewCell.animationDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.faceImageView.hidden = YES;
                        self.backImageView.hidden = YES;
                    }
                    completion:nil];
    _cardState = CardRemoved;
}

- (void)reset
{
    _cardState = CardFaceDown;
    self.faceImageView.hidden = YES;
    self.backImageView.hidden = NO;
}


+ (NSTimeInterval)animationDuration {
    return 0.5;
}


- (void)setFaceId:(NSNumber*)faceId {
    _faceId = faceId;
    self.faceImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", kCardFaceImagePrefix, faceId]];
}

@end

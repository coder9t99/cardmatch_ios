//
//  HighScoreViewCell.m
//  Card Match
//
//  Created by Quentin Lin on 8/05/2016.
//  Copyright © 2016 coder9t99. All rights reserved.
//

#import "HighScoreViewCell.h"

@interface HighScoreViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@end

@implementation HighScoreViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *nibs = [NSBundle.mainBundle loadNibNamed:@"HighScoreViewCell" owner:self options:nil];

        self = nibs.count > 0
            && [nibs[0] isKindOfClass:HighScoreViewCell.class]
             ? nibs[0]
             : nil;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setName:(NSString*)name {
    _name = name;
    self.nameLabel.text = _name;
}

- (void)setRank:(NSNumber*)rank {
    _rank = rank;
    self.rankLabel.text = [NSString stringWithFormat:@"#%@", _rank];
}

- (void)setScore:(NSNumber*)score {
    _score = score;
    self.scoreLabel.text = _score.stringValue;
}

@end

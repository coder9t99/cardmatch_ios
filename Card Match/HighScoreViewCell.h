//
//  HighScoreViewCell.h
//  Card Match
//
//  Created by Quentin Lin on 8/05/2016.
//  Copyright © 2016 Accedo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighScoreViewCell : UITableViewCell
@property (nonatomic, assign) NSNumber *rank;
@property (nonatomic, assign) NSString *name;
@property (nonatomic, assign) NSNumber *score;
@end

//
//  SettingsWatcher.h
//  Card Match
//
//  Created by Quentin Lin on 8/05/2016.
//  Copyright © 2016 Accedo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HighScoreSynchroniser.h"

@interface SettingsWatcher : NSObject

@property (readonly, strong) HighScoreSynchroniser *synchroniser;

- (instancetype)init;

- (void)syncHighScore;
@end

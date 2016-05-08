//
// Created by Quentin Lin on 7/05/2016.
// Copyright (c) 2016 coder9t99. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString * const kDataSyncComplete = @"DataSyncComplete";

@interface HighScoreSynchroniser : NSObject
-(instancetype)initWithHighScoreEndpoint:(NSString*)url;
-(void)sync;
@end

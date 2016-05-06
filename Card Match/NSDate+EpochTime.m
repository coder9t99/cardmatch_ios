//
// Created by Quentin Lin on 6/05/2016.
// Copyright (c) 2016 Accedo. All rights reserved.
//

#import "NSDate+EpochTime.h"


@implementation NSDate (EpochTime)
- (NSInteger)secondsFromEpoch {
    return (NSUInteger)(self.timeIntervalSince1970);
}

- (NSInteger)millisecondsFromEpoch {
    return (NSUInteger)(self.timeIntervalSince1970 * 1000.0);
}

@end

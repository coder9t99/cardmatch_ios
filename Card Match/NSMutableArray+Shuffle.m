//
// Created by Quentin Lin on 5/05/2016.
// Copyright (c) 2016 coder9t99. All rights reserved.
//

#import "NSMutableArray+Shuffle.h"

@implementation NSMutableArray (Shuffle)

- (void)shuffle
{
    for (NSUInteger i = self.count; i > 1; i--) {
        [self exchangeObjectAtIndex:i - 1
                  withObjectAtIndex:arc4random_uniform((u_int32_t) i)];
    }
}

@end
//
// Created by Quentin Lin on 8/05/2016.
// Copyright (c) 2016 Accedo. All rights reserved.
//

#import "NSString+isEmptyOrWhiteSpace.h"


@implementation NSString (isEmptyOrWhiteSpace)

- (BOOL)isEmptyOrWhiteSpace {
    return ([self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0);
}

@end
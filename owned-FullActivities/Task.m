//
//  CellContent.m
//  owned-FullActivities
//
//  Created by Huy on 6/18/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import "Task.h"

@implementation Task


- (instancetype)initWithLabel:(NSString *)label andWithPriority:(int)priority
{
    self = [super init];
    if (self) {
        _label = label;
        _priority = priority;
    }
    return self;
    
}

@end

//
//  TaskList.m
//  owned-FullActivities
//
//  Created by Huy on 6/18/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import "TaskList.h"
#import "Task.h"

@implementation TaskList

+ (instancetype)sharedTaskList {
    static TaskList *_sharedTaskList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedTaskList = [[TaskList alloc] init];
    });
    
    return _sharedTaskList;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tasks = [[NSMutableArray alloc] init];
        
        [_tasks addObject:[[NSMutableArray alloc] init]];
        [_tasks[0] addObject:[[Task alloc] initWithLabel:@"Email Bob" andWithPriority:0]];
        
        [_tasks addObject:[[NSMutableArray alloc] init]];
        [_tasks[1] addObject:[[Task alloc] initWithLabel:@"Clean Desk" andWithPriority:0]];
        
        [_tasks addObject:[[NSMutableArray alloc] init]];
        [_tasks[2] addObject:[[Task alloc] initWithLabel:@"Drink Coffee" andWithPriority:3]];
        [_tasks[2] addObject:[[Task alloc] initWithLabel:@"Take a nap" andWithPriority:0]];
        
        [_tasks addObject:[[NSMutableArray alloc] init]];
        [_tasks[3] addObject:[[Task alloc] initWithLabel:@"Check flight schedule" andWithPriority:0]];
    }
    return self;
}

@end

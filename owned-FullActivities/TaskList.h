//
//  TaskList.h
//  owned-FullActivities
//
//  Created by Huy on 6/18/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskList : NSObject

+ (TaskList *)sharedTaskList;

@property (nonatomic, strong) NSMutableArray *tasks;


@end

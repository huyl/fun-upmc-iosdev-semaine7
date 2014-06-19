//
//  CellContent.h
//  owned-FullActivities
//
//  Created by Huy on 6/18/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject

@property (nonatomic, strong) NSString *label;
@property (nonatomic) int priority;
@property (nonatomic, strong) UIImage *image;

- (instancetype)initWithLabel:(NSString *)label andWithPriority:(int)priority;

@end

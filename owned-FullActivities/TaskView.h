//
//  TaskView.h
//  owned-FullActivities
//
//  Created by Huy on 6/19/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface TaskView : UIView <UITextFieldDelegate>

- (instancetype)initWithTask:(Task *)task;

@property (nonatomic, weak) UIImage *image;

@end

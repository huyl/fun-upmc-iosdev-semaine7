//
//  TableViewController.h
//  owned-FullActivities
//
//  Created by Huy on 6/18/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;

- (instancetype)initWithStyle:(UITableViewStyle)style;

@end

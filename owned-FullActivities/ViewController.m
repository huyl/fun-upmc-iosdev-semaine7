//
//  ViewController.m
//  owned-FullActivities
//
//  Created by Huy on 6/18/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import "ViewController.h"
#import "TableViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) TableViewController *tableViewController;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    TableViewController *tableViewController = [[TableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.tableViewController = tableViewController;
    
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:self.tableViewController];
    self.navController = navController;
    [self.navController.view addSubview:self.tableViewController.view];
    
    [self.view addSubview:[navController view]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

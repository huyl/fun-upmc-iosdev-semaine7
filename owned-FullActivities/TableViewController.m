//
//  TableViewController.m
//  owned-FullActivities
//
//  Created by Huy on 6/18/14.
//  Copyright (c) 2014 huy. All rights reserved.
//
// Implemented my own ViewController instead of using UITableViewController because folks say that
// it's too limited.

#import "TableViewController.h"
#import "TaskViewController.h"
#import "TaskList.h"
#import "Task.h"

@interface TableViewController ()

@property (nonatomic, weak) UIBarButtonItem *addButton;
@property (nonatomic) UITableViewStyle tableViewStyle;

@end

@implementation TableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        _tableViewStyle = style;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// Table View
        
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:self.tableViewStyle];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    _tableView = tableView;
    [tableView reloadData];
    
    self.view = tableView;
    
    /// Navigation Bar
        
    self.navigationItem.title = @"Task List";
    
    // Display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:nil
                                                                               action:nil];
    _addButton = addButton;
    self.navigationItem.rightBarButtonItem = addButton;
    
    
    /// Rest
    
    [self setupRAC];
}


- (void)setupRAC
{
    @weakify(self);
    
    // React to add button click
    self.addButton.rac_action = [[RACSignal create:^(id<RACSubscriber> subscriber) {
        @strongify(self);
        
        NSArray *tasks = [[TaskList sharedTaskList] tasks];
        [tasks[0] addObject:[[Task alloc] initWithLabel:@"New task" andWithPriority:0]];
        NSUInteger indexes[] = {0, [tasks[0] count] - 1};
        NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:indexes length:2];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [subscriber sendCompleted];
    }] action];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
    [super setEditing:editing animated:animate];
    [self.tableView setEditing:editing animated:animate];

    NSArray *tasks = [[TaskList sharedTaskList] tasks];
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    for (int i = 0; i < [tasks count]; i++) {
        NSUInteger indexes[] = {i, [tasks[i] count]};
        [paths addObject:[[NSIndexPath alloc] initWithIndexes:indexes length:2]];
    }
    
    if (self.editing) {
        [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // A task may have been edited
    [self.tableView reloadData];
}

#pragma mark - Utility

- (BOOL)isAnInsertionRow:(NSIndexPath *)indexPath
{
    NSArray *tasks = [[TaskList sharedTaskList] tasks];
    
    return self.editing && indexPath.row == [tasks[indexPath.section] count];
}


#pragma mark - TableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing == NO || !indexPath)
        return UITableViewCellEditingStyleNone;
    
    NSArray *tasks = [[TaskList sharedTaskList] tasks];
    
    if (self.editing && indexPath.row == ([tasks[indexPath.section] count]))
        return UITableViewCellEditingStyleInsert;
    else
        return UITableViewCellEditingStyleDelete;
    
    return UITableViewCellEditingStyleNone;
}

// Override to disallow moving cells below the Insertion Row
- (NSIndexPath *)               tableView:(UITableView *)tableView
 targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
                      toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    NSArray *tasks = [[TaskList sharedTaskList] tasks];
    
    // No insertion
    if (proposedDestinationIndexPath.row >= [tasks[proposedDestinationIndexPath.section] count]) {
        NSUInteger indexes[] = {proposedDestinationIndexPath.section, proposedDestinationIndexPath.row - 1};
        return [[NSIndexPath alloc] initWithIndexes:indexes length:2];
    } else {
        return proposedDestinationIndexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *tasks = [[TaskList sharedTaskList] tasks];
    TaskViewController *taskViewController = [[TaskViewController alloc]
                                              initWithTask:tasks[indexPath.section][indexPath.row]];
    [self.navigationController pushViewController:taskViewController animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[TaskList sharedTaskList] tasks] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [[[[TaskList sharedTaskList] tasks] objectAtIndex:section] count];
    
    // Add one if we're editing (for the "Add task" row)
    if (self.editing) {
        count++;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"any";
    
    // NOTE: must not use `forIndexPath:` variant if you want to do UITableViewCellStyleSubtitle programmatically
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    if ([self isAnInsertionRow:indexPath]) {
        cell.textLabel.text = @"Add a task";
    } else {
        NSArray *tasks = [[TaskList sharedTaskList] tasks];
        Task *task = tasks[indexPath.section][indexPath.row];
        cell.textLabel.text = task.label;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Current Priority : %d", task.priority];
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"prio%d.png", task.priority]];
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)    tableView:(UITableView *)tableView
   commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    NSArray *tasks = [[TaskList sharedTaskList] tasks];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tasks[section] removeObjectAtIndex:row];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [tasks[section] addObject:[[Task alloc] initWithLabel:@"New task" andWithPriority:0]];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ![self isAnInsertionRow:indexPath];
}

// Override to support rearranging the table view.
- (void)    tableView:(UITableView *)tableView
   moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
          toIndexPath:(NSIndexPath *)toIndexPath
{
    NSInteger fromSection = [fromIndexPath section];
    NSInteger fromRow = [fromIndexPath row];
    NSInteger toSection = [toIndexPath section];
    NSInteger toRow = [toIndexPath row];
    
    NSArray *tasks = [[TaskList sharedTaskList] tasks];
    Task *task = tasks[fromSection][fromRow];
    [tasks[fromSection] removeObjectAtIndex:fromRow];
    [tasks[toSection] insertObject:task atIndex:toRow];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end

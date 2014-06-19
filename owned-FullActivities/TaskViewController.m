//
//  TaskViewController.m
//  owned-FullActivities
//
//  Created by Huy on 6/19/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import "TaskViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "TaskView.h"

@interface TaskViewController ()

@property (nonatomic, weak) Task *task;

@property (nonatomic, weak) UIBarButtonItem *photoButton;
@property (nonatomic, weak) TaskView *taskView;

@property (nonatomic, strong) UIImagePickerController *picker;

@property (nonatomic, strong) UIPopoverController *photoPickerPopover;

@end

@implementation TaskViewController


- (instancetype)initWithTask:(Task *)task
{
    self = [super init];
    if (self) {
        _task = task;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TaskView *taskView = [[TaskView alloc] initWithTask:self.task];
    self.taskView = taskView;
    self.view = taskView;

    UIBarButtonSystemItem item;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        item = UIBarButtonSystemItemCamera;
    } else {
        // TODO: have a photo gallery icon instead
        item = UIBarButtonSystemItemCamera;
    }
    UIBarButtonItem *photoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:item target:nil action:nil];
    _photoButton = photoButton;
    self.navigationItem.rightBarButtonItem = photoButton;
    
    [self setupRAC];
}


- (void)setupRAC
{
    @weakify(self);
    
    // React to add button click
    self.photoButton.rac_action = [[RACSignal create:^(id<RACSubscriber> subscriber) {
        @strongify(self);
        
        if (!self.picker) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = (TaskViewController<UIImagePickerControllerDelegate> *)self;
            self.picker = picker;
        }
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            NSArray *mediaTypes = [UIImagePickerController
                                   availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            self.picker.mediaTypes = mediaTypes;
        } else {
            self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        self.picker.allowsEditing = NO;
        
        if (IS_IPAD) {
            self.photoPickerPopover = [[UIPopoverController alloc] initWithContentViewController:self.picker];
            [self.photoPickerPopover presentPopoverFromBarButtonItem:self.photoButton
                                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                                             animated:YES];
        } else {
            UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
            [rootVC presentViewController:self.picker animated:YES completion:nil];
        }
        
        [subscriber sendCompleted];
    }] action];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.picker dismissViewControllerAnimated:YES completion:nil];
    self.picker = nil;
    
    // For ipad mode, dismiss any popover
    if (self.photoPickerPopover) {
        [self.photoPickerPopover dismissPopoverAnimated:YES];
        self.photoPickerPopover = nil;
    }
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (!image) {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        self.taskView.image = image;
    }
}

@end

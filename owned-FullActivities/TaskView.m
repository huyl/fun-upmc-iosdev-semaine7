//
//  TaskView.m
//  owned-FullActivities
//
//  Created by Huy on 6/19/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import "TaskView.h"
#import "Masonry.h"

@interface TaskView ()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UITextField *titleField;
@property (nonatomic, weak) UILabel *priorityLabel;
@property (nonatomic, weak) UISegmentedControl *prioritySeg;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, weak) Task *task;

@end

@implementation TaskView

- (instancetype)initWithTask:(Task *)task
{
    self = [super init];
    if (self) {
        _task = task;
        
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"Title:";
        titleLabel.textAlignment = NSTextAlignmentRight;
        _titleLabel = titleLabel;
        [self addSubview:titleLabel];
        
        UITextField *titleField = [[UITextField alloc] init];
        titleField.text = task.label;
        titleField.borderStyle = UITextBorderStyleRoundedRect;
        titleField.returnKeyType = UIReturnKeyDone;
        titleField.delegate = self;
        _titleField = titleField;
        [self addSubview:titleField];
        
        UILabel *priorityLabel = [[UILabel alloc] init];
        priorityLabel.text = @"Priority:";
        priorityLabel.textAlignment = NSTextAlignmentRight;
        _priorityLabel = priorityLabel;
        [self addSubview:priorityLabel];
        
        UISegmentedControl *prioritySeg = [[UISegmentedControl alloc] init];
        [prioritySeg addTarget:self
                        action:@selector(priorityChanged:)
              forControlEvents:UIControlEventValueChanged];
        _prioritySeg = prioritySeg;
        for (int i = 0; i < 5; i++) {
            [prioritySeg insertSegmentWithTitle:[NSString stringWithFormat:@"%d", i] atIndex:i animated:NO];
            [prioritySeg setWidth:40 forSegmentAtIndex:i];
        }
        prioritySeg.selectedSegmentIndex = task.priority;
        [self addSubview:prioritySeg];
        
        // TODO: Change this unnecesary ScrollView to a UIView (which is still needed because it's
        // resized by auto-layout, while we manually resize the ImageView to maintain aspect ratio)
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        _scrollView = scrollView;
        [self addSubview:scrollView];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = task.image;
        _imageView = imageView;
        [scrollView addSubview:imageView];
        
        [self setupConstraints];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self resizeImageView];
}

#pragma mark - Constraints

- (void)setupConstraints
{
    UIView *superview = self;
    
    // Config
    UIEdgeInsets padding = UIEdgeInsetsMake(32, 10, 10, 10);
    UIOffset internal = UIOffsetMake(15, 15);
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        // TODO: compute the offset given the navigation bard instead of hard-coding
        make.top.equalTo(superview).with.offset(padding.top + 50);
        make.left.equalTo(superview).with.offset(padding.left);
    }];
    
    [self.titleField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel.mas_centerY);
        make.left.equalTo(self.titleLabel.mas_right).with.offset(internal.horizontal);
        make.right.equalTo(superview).with.offset(-padding.right);
    }];
    
    [self.priorityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(internal.vertical);
        make.right.equalTo(self.titleLabel);
        make.left.equalTo(superview).with.offset(padding.left);
        // We have to fix the width because the titleField may grow when it has a lot of text, which would
        // shift this label.
        make.width.equalTo(@(60));
    }];
    
    [self.prioritySeg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.priorityLabel);
        make.left.equalTo(self.priorityLabel.mas_right).with.offset(internal.horizontal);
        make.right.equalTo(superview).with.offset(-padding.right).with.priorityLow();
    }];
    
    // TODO: figure out how to center the scrollView horizontally
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.prioritySeg.mas_bottom).with.offset(internal.vertical);;
        make.left.equalTo(superview).with.offset(padding.left);
        make.right.equalTo(superview).with.offset(-padding.right);
        make.bottom.equalTo(superview).with.offset(-padding.bottom).with.priorityLow();
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.task.label = self.titleField.text;
}

#pragma mark - UISegmentedControl actions

- (void)priorityChanged:(id)sender
{
    self.task.priority = self.prioritySeg.selectedSegmentIndex;
}

#pragma mark - UIImage

- (void)resizeImageView
{
    CGSize size = self.scrollView.frame.size;
    
    CGRect frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    
    // Scale image to fit, preserving aspect ratio
    float scale = 1.0;
    if (frame.size.width > size.width) {
        scale = (CGFloat)size.width / frame.size.width;
    }
    if (frame.size.height > size.height) {
        float vScale = (CGFloat)size.height / frame.size.height;
        if (vScale < scale) {
            scale = vScale;
        }
    }
    frame.size.width = (CGFloat) frame.size.width * scale;
    frame.size.height = (CGFloat) frame.size.height * scale;
    
    self.imageView.frame = frame;
}

- (void)setImage:(UIImage *)image
{
    self.task.image = image;
    self.imageView.image = image;

    [self resizeImageView];
}

- (UIImage *)image
{
    return self.imageView.image;
}

@end

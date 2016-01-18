//
//  ReplaceTextViewController.m
//  MSPTouchableLabel
//
//  Created by Michael Pace on 4/12/15.
//  Copyright (c) 2015 Michael Pace. All rights reserved.
//

#import "ReplaceTextViewController.h"
#import "MSPTouchableLabel.h"

#define kMSPEwwUnicode      @"\U0001F4A9"

@interface ReplaceTextViewController ()<MSPTouchableLabelDataSource, MSPTouchableLabelDelegate>

@property (nonatomic, strong) NSArray* substrings;
@property (nonatomic, strong) NSMutableArray* ewws;
@property (weak, nonatomic) IBOutlet MSPTouchableLabel *touchableLabel;

@end

@implementation ReplaceTextViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.touchableLabel.dataSource = self;
    self.touchableLabel.delegate = self;
    self.touchableLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0f];
    
    self.substrings = @[@"Hello", @", ", @"how", @" ", @"are", @" ", @"you", @"?"];
    
    self.ewws = [[NSMutableArray alloc] initWithCapacity:self.substrings.count];
    for (NSUInteger i = 0; i < self.substrings.count; i++) {
        [self.ewws addObject:@NO];
    }
}

#pragma mark - MSPTouchableLabelDataSource

- (NSArray*)textForTouchableLabel:(MSPTouchableLabel*)touchableLabel {
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.substrings.count];
    
    for (NSUInteger i = 0; i < self.substrings.count; i++) {
        if ([self.ewws[i] boolValue]) {
            [result addObject:kMSPEwwUnicode];
        } else {
            [result addObject:self.substrings[i]];
        }
    }
    
    return result;
}

#pragma mark - MSPTouchableLabelDelegate

- (void)touchableLabel:(MSPTouchableLabel*)touchableLabel touchesDidEndAtIndex:(NSInteger)index {
    // only replace words, not whitespace or punctuation. (in a real app you'd want a more robust way to check for valid indices than this).
    if (index % 2 == 0) {
        self.ewws[index] = @(![self.ewws[index] boolValue]);
    }
}

@end

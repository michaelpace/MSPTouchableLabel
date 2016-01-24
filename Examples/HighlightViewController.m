//
//  HighlightViewController.m
//  MSPTouchableLabel
//
//  Created by Michael Pace on 12/8/15.
//  Copyright © 2015 Michael Pace. All rights reserved.
//

#import "HighlightViewController.h"
#import "MSPTouchableLabel.h"

@interface HighlightViewController ()<MSPTouchableLabelDataSource, MSPTouchableLabelDelegate>

@property (weak, nonatomic) IBOutlet MSPTouchableLabel *touchableLabel;

@property (nonatomic, strong) NSArray* paragraphSubstrings;
@property (nonatomic, strong) NSNumber* lastTouchedIndex;
@property (assign) NSRange highightedRange;

@end

@implementation HighlightViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* paragraph = @"The male painted bunting is often described as the most beautiful bird in North America and as such has been nicknamed nonpareil, or \"without equal\". Its colors, dark blue head, green back, red rump, and underparts, make it extremely easy to identify, but it can still be difficult to spot since it often skulks in foliage even when it is singing.";
    NSMutableArray* charactersInParagraph = [[NSMutableArray alloc] init];
    NSUInteger i = 0;
    while (i < paragraph.length) {
        NSRange range = [paragraph rangeOfComposedCharacterSequenceAtIndex:i];
        NSString* characterString = [paragraph substringWithRange:range];
        [charactersInParagraph addObject:characterString];
        i += range.length;
    }
    self.paragraphSubstrings = charactersInParagraph;
    
    self.highightedRange = NSMakeRange(0, 0);
    
    self.touchableLabel.dataSource = self;
    self.touchableLabel.delegate = self;
    self.touchableLabel.multiLineRenderingOptimizationsEnabled = NO;
    self.touchableLabel.font = [UIFont fontWithName:@"Helvetica" size:18.0f];
    self.touchableLabel.backgroundColor = [UIColor clearColor];
}

#pragma mark - MSPTouchableLabelDataSource

- (NSArray*)textForTouchableLabel:(MSPTouchableLabel*)touchableLabel {
    return self.paragraphSubstrings;
}

- (NSDictionary*)attributesForTouchableLabel:(MSPTouchableLabel*)touchableLabel atIndex:(NSInteger)index {
    NSUInteger endOfHighlight = self.highightedRange.location + self.highightedRange.length;
    if (self.highightedRange.location <= index && index < endOfHighlight) {
        return @{ NSBackgroundColorAttributeName: [UIColor yellowColor] };
    }
    
    return nil;
}

#pragma mark - MSPTouchableLabelDelegate

- (void)touchableLabel:(MSPTouchableLabel*)touchableLabel touchesDidBeginAtIndex:(NSInteger)index {
    // highlight current index
    self.highightedRange = NSMakeRange(index, 1);
    self.lastTouchedIndex = @(index);
}

- (void)touchableLabel:(MSPTouchableLabel*)touchableLabel touchesDidMoveToIndex:(NSInteger)index {
    NSInteger lowerIndex = index < self.lastTouchedIndex.integerValue ? index : self.lastTouchedIndex.integerValue;
    NSInteger higherIndex = lowerIndex == index ? self.lastTouchedIndex.integerValue : index;
    self.highightedRange = NSMakeRange(lowerIndex, higherIndex - lowerIndex + 1);
}

- (void)touchableLabel:(MSPTouchableLabel*)touchableLabel touchesDidEndAtIndex:(NSInteger)index {
    self.lastTouchedIndex = nil;
}

@end

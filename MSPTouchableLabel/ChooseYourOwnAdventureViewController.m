//
//  ChooseYourOwnAdventureViewController.m
//  MSPTouchableLabel
//
//  Created by Michael Pace on 12/8/15.
//  Copyright © 2015 Michael Pace. All rights reserved.
//

#import "ChooseYourOwnAdventureViewController.h"
#import "MSPTouchableLabel.h"

#define kMSPIndexApproachCastle     1
#define kMSPIndexContinuePastCastle 3

@interface ChooseYourOwnAdventureViewController ()<MSPTouchableLabelDataSource, MSPTouchableLabelDelegate>

@property (weak, nonatomic) IBOutlet MSPTouchableLabel *touchableLabel;

@end

@implementation ChooseYourOwnAdventureViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.touchableLabel.delegate = self;
    self.touchableLabel.dataSource = self;
    self.touchableLabel.defaultAttributes = [self attributesForNormalSubstring];
}

#pragma mark - MSPTouchableLabelDataSource

- (NSArray*)textForTouchableLabel:(MSPTouchableLabel*)touchableLabel {
    return @[@"You see a large castle in the distance. Your rations are running low and you aren't sure how much further it'll be until you see another sign of civilization. You consider ",
             @"approaching the castle",
             @", but you're also wary of what it may contain. Your donkey Rufus breathes a heavy sigh of exhaustion. Your other option is to ",
             @"continue past the castle",
             @"."];
}

- (NSDictionary*)attributesForTouchableLabel:(MSPTouchableLabel*)touchableLabel atIndex:(NSInteger)index {
    if (index == kMSPIndexApproachCastle || index == kMSPIndexContinuePastCastle) {
        return [self attributesForTappableSubstring];
    }
    
    return nil;
}

#pragma mark - MSPTouchableLabelDelegate

- (void)touchableLabel:(MSPTouchableLabel*)touchableLabel touchesDidEndAtIndex:(NSInteger)index {
    if (index == kMSPIndexApproachCastle) {
        [[[UIAlertView alloc] initWithTitle:@"What luck..." message:@"You approach the castle but it turns out to belong to Dracula. You're a goner, and Rufus is too." delegate:nil cancelButtonTitle:@"Dratz!!" otherButtonTitles:nil] show];
    } else if (index == kMSPIndexContinuePastCastle) {
        [[[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"You continue on for days and your resources slowly dwindle. Rufus abandons you, and you go until you can't go any longer." delegate:nil cancelButtonTitle:@"\U0001F62D" otherButtonTitles:nil] show];
    }
}

#pragma mark - ()

- (NSDictionary*)attributesForNormalSubstring {
    return @{
             NSFontAttributeName:[UIFont systemFontOfSize:18.0f],
             NSForegroundColorAttributeName: [UIColor blackColor]
             };
}

- (NSDictionary*)attributesForTappableSubstring {
    return @{
             NSFontAttributeName:[UIFont boldSystemFontOfSize:18.0f],
             NSForegroundColorAttributeName: [UIColor colorWithRed:165.0f/255.0f green:88.0f/255.0f blue:88.0f/255.0f alpha:1.0f]
             };
}

@end

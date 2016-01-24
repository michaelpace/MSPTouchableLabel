//
//  MadLibsViewController.m
//  MSPTouchableLabel
//
//  Created by Michael Pace on 12/7/15.
//  Copyright © 2015 Michael Pace. All rights reserved.
//

#import "MadLibsViewController.h"
#import "MSPTouchableLabel.h"

#define kMSPMadLibBlankSpaceString  @"____"
#define kMSPAlphaInvisible          0.0f
#define kMSPAlphaVisible            1.0f
#define kMSPAnimationDuration       0.3f

@interface MadLibsViewController ()<MSPTouchableLabelDataSource, MSPTouchableLabelDelegate>

@property (weak, nonatomic) IBOutlet MSPTouchableLabel *touchableLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, strong) NSMutableArray* madLibTexts;
@property (nonatomic, strong) NSNumber* selectedIndex;

@end

@implementation MadLibsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.touchableLabel.dataSource = self;
    self.touchableLabel.delegate = self;
    self.touchableLabel.font = [UIFont fontWithName:@"Helvetica" size:32.0f];
    
    self.textField.alpha = kMSPAlphaInvisible;
    
    self.madLibTexts = [NSMutableArray arrayWithArray:@[
                                                        kMSPMadLibBlankSpaceString,
                                                        @" and ",
                                                        kMSPMadLibBlankSpaceString,
                                                        @" love to ",
                                                        kMSPMadLibBlankSpaceString,
                                                        @" by the ",
                                                        kMSPMadLibBlankSpaceString,
                                                        @"."
                                                        ]];
    
    UITapGestureRecognizer* dismissKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    dismissKeyboardTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:dismissKeyboardTap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:@"UITextFieldTextDidChangeNotification" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - MSPTouchableLabelDataSource

- (NSArray*)textForTouchableLabel:(MSPTouchableLabel*)touchableLabel {
    return self.madLibTexts;
}

- (NSDictionary*)attributesForTouchableLabel:(MSPTouchableLabel*)touchableLabel atIndex:(NSInteger)index {
    if ([self madLibSpaceAtIndexIsEditable:index]) {
        return @{ NSForegroundColorAttributeName: [UIColor grayColor] };
    }
    
    return nil;
}

#pragma mark - MSPTouchableLabelDelegate

- (void)touchableLabel:(MSPTouchableLabel*)touchableLabel touchesDidEndAtIndex:(NSInteger)index {
    if ([self madLibSpaceAtIndexIsEditable:index]) {
        self.selectedIndex = @(index);
        
        NSString* startingText = self.madLibTexts[index];
        if ([startingText isEqualToString:kMSPMadLibBlankSpaceString]) {
            startingText = @"";
        }
        self.textField.text = startingText;
        
        [self showTextField];
    }
}

#pragma mark - Actions

- (void)textFieldDidChange:(NSNotification*)notification {
    NSString* newText = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (newText.length == 0) {
        newText = kMSPMadLibBlankSpaceString;
    }
    
    self.madLibTexts[self.selectedIndex.integerValue] = newText;
    [self.touchableLabel setNeedsDisplay];
}

- (void)dismissKeyboard {
    [self hideTextField];
}

#pragma mark - ()

- (void)showTextField {
    [self.textField becomeFirstResponder];
    [UIView animateWithDuration:kMSPAnimationDuration animations:^{
        self.textField.alpha = kMSPAlphaVisible;
    }];
}

- (void)hideTextField {
    [self.textField resignFirstResponder];
    [UIView animateWithDuration:kMSPAnimationDuration animations:^{
        self.textField.alpha = kMSPAlphaInvisible;
    }];
}

- (BOOL)madLibSpaceAtIndexIsEditable:(NSInteger)index {
    return index % 2 == 0;
}

@end

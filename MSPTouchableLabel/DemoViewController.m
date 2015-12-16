//
//  DemoViewController.m
//  MSPTouchableLabel
//
//  Created by Michael Pace on 12/8/15.
//  Copyright © 2015 Michael Pace. All rights reserved.
//

#import "DemoViewController.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton* closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 68.0f, 20.0f, 60.0f, 40.0f)];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
}

#pragma mark - Actions

- (IBAction)closeButtonTapped:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

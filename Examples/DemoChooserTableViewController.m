//
//  DemoChooserTableViewController.m
//  MSPTouchableLabel
//
//  Created by Michael Pace on 12/7/15.
//  Copyright © 2015 Michael Pace. All rights reserved.
//

#import "DemoChooserTableViewController.h"
#import "ReplaceTextViewController.h"
#import "MadLibsViewController.h"

@interface DemoChooserTableViewController ()

@property (nonatomic, strong) NSArray* demos;

@end

@implementation DemoChooserTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // prevent table view from extending below status bar
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 48)];
    
    self.demos = @[
      @{
          @"title": @"Replace text",
          @"instance": [self.storyboard instantiateViewControllerWithIdentifier:@"ReplaceTextViewController"]
      },
      @{
          @"title": @"Choose your own adventure",
          @"instance": [self.storyboard instantiateViewControllerWithIdentifier:@"ChooseYourOwnAdventureViewController"]
      },
      @{
          @"title": @"Open link",
          @"instance": [self.storyboard instantiateViewControllerWithIdentifier:@"OpenLinkViewController"]
      },
      @{
          @"title": @"Mad libs",
          @"instance": [self.storyboard instantiateViewControllerWithIdentifier:@"MadLibsViewController"]
      },
      @{
          @"title": @"Highlight",
          @"instance": [self.storyboard instantiateViewControllerWithIdentifier:@"HighlightViewController"]
      },
  ];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demos.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"demoCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"demoCell"];
    }
    
    cell.textLabel.text = [self.demos[indexPath.row] objectForKey:@"title"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    UIViewController* demo = [self.demos[indexPath.row] objectForKey:@"instance"];
    [self presentViewController:demo animated:YES completion:nil];
}

@end
//
//  OpenLinkViewController.m
//  MSPTouchableLabel
//
//  Created by Michael Pace on 12/10/15.
//  Copyright © 2015 Michael Pace. All rights reserved.
//

#import "OpenLinkViewController.h"
#import "MSPTouchableLabel.h"

#define kMSPIndexGoogle     1
#define kMSPIndexWikipedia  3

@interface OpenLinkViewController ()<MSPTouchableLabelDataSource, MSPTouchableLabelDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet MSPTouchableLabel *touchableLabel;
@property (weak, nonatomic) IBOutlet UIView *webviewContainerView;
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@end

@implementation OpenLinkViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.touchableLabel.dataSource = self;
    self.touchableLabel.delegate = self;
    self.touchableLabel.defaultAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:26.0f] };
    
    self.webviewContainerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.webviewContainerView.layer.borderWidth = 1.0f;
    self.webviewContainerView.layer.cornerRadius = 8.0f;
    
    self.webviewContainerView.hidden = YES;
    self.loadingLabel.hidden = YES;
    self.webview.delegate = self;
    
    self.loadingLabel.transform = CGAffineTransformMakeRotation(-0.667f);
}

#pragma mark - MSPTouchableLabelDataSource

- (NSArray*)textForTouchableLabel:(MSPTouchableLabel*)touchableLabel {
    return @[@"Check out ", @"Google", @" or ", @"Wikipedia", @"!"];
}

- (NSDictionary*)attributesForTouchableLabel:(MSPTouchableLabel*)touchableLabel atIndex:(NSInteger)index {
    if (index == kMSPIndexGoogle || index == kMSPIndexWikipedia) {
        return @{
                 NSForegroundColorAttributeName: [UIColor blueColor],
                 NSUnderlineStyleAttributeName: @1
                 };
    }
    
    return nil;
}

#pragma mark - MSPTouchableLabelDelegate

- (void)touchableLabel:(MSPTouchableLabel*)touchableLabel touchesDidEndAtIndex:(NSInteger)index {
    if (index == kMSPIndexGoogle) {
        [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com"]]];
    } else if (index == kMSPIndexWikipedia) {
        [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.wikipedia.org"]]];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView*)webView {
    self.webviewContainerView.hidden = NO;
    self.webview.hidden = YES;
    self.loadingLabel.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
    self.webview.hidden = NO;
    self.loadingLabel.hidden = YES;
}

@end

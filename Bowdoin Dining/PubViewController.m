//
//  PubViewController.m
//  Bowdoin Dining
//
//  Created by Ruben on 7/15/14.
//
//

#import <Foundation/Foundation.h>
#import "PubViewController.h"

@interface PubViewController ()
@end

//Pub View Controller
@implementation PubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //open menu PDF in WebView
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"magees-menu" withExtension:@"pdf"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self.MageesMenu loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
    //hide the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

@end
//
//  SettingsViewController.m
//  Bowdoin Dining
//
//  Created by Ruben on 7/13/14.
//
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "SettingsViewController.h"

@interface SettingsViewController ()
@end

@implementation SettingsViewController
AppDelegate *delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    delegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewWillAppear:(BOOL)animated {
    
}

//user selected a filter (or turnd off)
- (IBAction)indexDidChangeForSegmentedControl: (UISegmentedControl *) sender {
    //remove all active filters, add a new one if selected
    [delegate.filters removeAllObjects];
    switch(sender.selectedSegmentIndex) {
        case 0:
            [delegate.filters addObject: @"V"];
            [delegate.filters addObject: @"VE"];
            break;
        case 1:
            [delegate.filters addObject: @"VE"];
            break;
        case 2:
            [delegate.filters addObject: @"GF"];
            break;
        case 3:
            [delegate.filters addObject: @"L"];
            break;
        default:
            break;
    }

}
@end
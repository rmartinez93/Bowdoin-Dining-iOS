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
    //if a filter was set, set it again in the view
    [self.dietFilter setSelectedSegmentIndex: [[NSUserDefaults standardUserDefaults] integerForKey:@"diet-filter"]];
}

//user selected a filter (or turnd off)
- (IBAction)indexDidChangeForSegmentedControl: (UISegmentedControl *) sender {
    //tell delegate to update diet filter
    [delegate updateDietFilter:sender.selectedSegmentIndex];
    
    //save to preferences
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:self.dietFilter.selectedSegmentIndex forKey:@"diet-filter"];
    [userDefaults synchronize];
}

@end
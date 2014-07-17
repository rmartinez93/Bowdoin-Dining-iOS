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
    //hide the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //if a filter was set, set it again in the view
    [self.dietFilter setSelectedSegmentIndex: [[NSUserDefaults standardUserDefaults] integerForKey:@"diet-filter"]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:@"bowdoin_username"];
    NSString *password = [userDefaults objectForKey:@"bowdoin_password"];
    if(!username || !password) {
        [self.logoutButton setEnabled: FALSE];
        [self.logoutButton setBackgroundColor:[UIColor lightGrayColor]];
    }
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

- (IBAction)logout:(UIButton *)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey: @"bowdoin_username"];
    [userDefaults removeObjectForKey: @"bowdoin_password"];
    [userDefaults synchronize];
    [self.logoutButton setEnabled: FALSE];
    [self.logoutButton setBackgroundColor:[UIColor lightGrayColor]];
}
@end
//
//  SettingsViewController.h
//  Bowdoin Dining
//
//  Created by Ruben on 7/13/14.
//
//

#import <UIKit/UIKit.h>
@interface SettingsViewController : UIViewController
- (IBAction)indexDidChangeForSegmentedControl: (UISegmentedControl *) sender;
- (IBAction)logout:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dietFilter;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@end
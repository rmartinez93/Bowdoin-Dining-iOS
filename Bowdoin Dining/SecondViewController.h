//
//  SecondViewController.h
//  Bowdoin Dining
//
//  Created by Ruben on 7/11/14.
//
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *meals;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UITableView *menuItems;
- (IBAction)indexDidChangeForSegmentedControl: sender;
@end
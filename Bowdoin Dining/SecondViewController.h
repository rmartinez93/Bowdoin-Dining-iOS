//
//  SecondViewController.h
//  Bowdoin Dining
//
//  Created by Ruben on 7/11/14.
//
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *menuItems;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UISegmentedControl *meals;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (strong, nonatomic) NSMutableArray *courses;
- (IBAction)indexDidChangeForSegmentedControl: sender;
- (IBAction)backButtonPressed: sender;
- (IBAction)forwardButtonPressed: sender;
@end
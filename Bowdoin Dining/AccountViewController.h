//
//  AccountViewController.h
//  Bowdoin Dining
//
//  Created by Ruben on 7/16/14.
//
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface AccountViewController : UIViewController
- (IBAction)userDidLogin:(UIStoryboardSegue *)segue;
- (IBAction)userCancelledLogin:(UIStoryboardSegue *)segue;
- (IBAction)presentLoginViewController:(UIButton *)sender;
- (void)userDidLoad:(NSNotification *) notification;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) User* user;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingPoints;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingMeals;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingBalance;
@property (weak, nonatomic) IBOutlet UILabel *meals;
@property (weak, nonatomic) IBOutlet UILabel *balance;
@property (weak, nonatomic) IBOutlet UILabel *points;

@end

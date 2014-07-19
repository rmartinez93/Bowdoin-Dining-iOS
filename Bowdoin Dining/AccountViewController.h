//
//  AccountViewController.h
//  Bowdoin Dining
//
//  Created by Ruben on 7/16/14.
//
//

#import <UIKit/UIKit.h>

@interface AccountViewController : UIViewController
- (void)userDidLoad:(NSNotification *) notification;
- (IBAction)userDidLogin:(UIStoryboardSegue *)segue;
- (IBAction)userCancelledLogin:(UIStoryboardSegue *)segue;
- (IBAction)reloadData:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingData;
@property (weak, nonatomic) IBOutlet UILabel *meals;
@property (weak, nonatomic) IBOutlet UILabel *balance;
@property (weak, nonatomic) IBOutlet UILabel *points;

@end

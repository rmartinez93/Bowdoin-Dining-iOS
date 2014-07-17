//
//  LoginViewController.h
//  Bowdoin Dining
//
//  Created by Ruben on 7/16/14.
//
//


#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
- (IBAction)login:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UISwitch *remember;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loggingIn;
@property (weak, nonatomic) IBOutlet UITextView *instructions;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

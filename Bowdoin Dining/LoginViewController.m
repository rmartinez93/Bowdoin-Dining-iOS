//
//  LoginViewController.m
//  Bowdoin Dining
//
//  Created by Ruben on 7/16/14.
//
//

#import <Foundation/Foundation.h>
#import "LoginViewController.h"
#import "AccountViewController.h"
#import "User.h"

@interface LoginViewController ()
@end

//Account View Controller
@implementation LoginViewController
- (void)viewDidLoad {
}

- (IBAction)login:(id)sender {
    [self.loggingIn startAnimating];
    [self.loginButton setTitle:@"    " forState:UIControlStateNormal];
    [self.usernameField setEnabled:FALSE];
    [self.passwordField setEnabled:FALSE];

    //create a new thread...
    dispatch_queue_t downloadQueue = dispatch_queue_create("Download queue", NULL);
    dispatch_async(downloadQueue, ^{
        //in new thread, load user info
        User* thisUser = [[User alloc] initWithUsername:[self.usernameField text] password:[self.passwordField text]];
        //go back to main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            //check if we got a response
            if(thisUser == nil) {
                [self.loggingIn stopAnimating];
                [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
                [self.instructions setTextColor:[UIColor redColor]];
                [self.usernameField setEnabled:TRUE];
                [self.passwordField setEnabled:TRUE];
                [self.instructions setText: @"Sorry, that username or password is invalid."];
            } else {
                if(self.remember.isOn) {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject: [self.usernameField text] forKey: @"bowdoin_username"];
                    [userDefaults setObject: [self.passwordField text] forKey: @"bowdoin_password"];
                    [userDefaults synchronize];
                }
                
                [self performSegueWithIdentifier:@"userDidLogin" sender:self];
                [self.loggingIn stopAnimating];
            }
        });
    });
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField; {
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (IBAction)nextItem:(UITextField *)textField {
        NSInteger nextTag = textField.tag + 1;
        // Try to find next responder
        UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
        if (nextResponder) {
            // Found next responder, so set it.
            [nextResponder becomeFirstResponder];
        } else {
            // Not found, so remove keyboard.
            [textField resignFirstResponder];
        }
}

- (IBAction)hideKeyboard:(UITextField *)textField {
    [textField resignFirstResponder];
}

@end
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIButton *trigger = (UIButton *)sender;
    //login button
    if(trigger.tag == 0) {
        //create a new thread...
        dispatch_queue_t downloadQueue = dispatch_queue_create("Download queue", NULL);
        dispatch_async(downloadQueue, ^{
            //in new thread, load user; automatically returned by NSNotificationCenter
            [[User alloc] initWithUsername:[self.usernameField text] password:[self.passwordField text]];
        });
    }
    
    //cancel button
    if(trigger.tag == 1) {

    }
}

@end
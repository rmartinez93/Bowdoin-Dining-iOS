//
//  AccountViewController.m
//  Bowdoin Dining
//
//  Created by Ruben on 7/16/14.
//
//

#import <Foundation/Foundation.h>
#import "AccountViewController.h"
#import "LoginViewController.h"

@interface AccountViewController ()
@end

//Account View Controller
@implementation AccountViewController
- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLoad:)
                                                 name:@"UserFinishedLoading"
                                               object:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:@"bowdoin_username"];
    NSString *password = [userDefaults objectForKey:@"bowdoin_password"];
    if(username && password) {
        dispatch_queue_t downloadQueue = dispatch_queue_create("Download queue", NULL);
        dispatch_async(downloadQueue, ^{
            //in new thread, load user info
            [[User alloc] initWithUsername:username password:password];
        });
    } else {
        [self.loginButton setHidden: TRUE];
        [self performSegueWithIdentifier:@"LoginAction" sender:self];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if(self.user != nil) {
        //we're logged in
    }
}

- (IBAction)userCancelledLogin:(UIStoryboardSegue *)segue {
    [self.loginButton setHidden: FALSE];
}

- (IBAction)userDidLogin:(UIStoryboardSegue *)segue {
    [self.loginButton    setHidden: TRUE];
    [self.loadingPoints  startAnimating];
    [self.loadingMeals   startAnimating];
    [self.loadingBalance startAnimating];
}

-(void)userDidLoad:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    self.user = [userInfo objectForKey:@"User"];
    [self.loadingPoints  stopAnimating];
    [self.loadingMeals   stopAnimating];
    [self.loadingBalance stopAnimating];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.points  setText: [NSString stringWithFormat:@"$%.2f", self.user.polarPoints]];
        [self.meals   setText: [NSString stringWithFormat:@"%i", self.user.mealsLeft]];
        [self.balance setText: [NSString stringWithFormat:@"$%.2f", self.user.cardBalance]];
    });
}

- (IBAction)presentLoginViewController:(UIButton *)sender {
    NSLog(@"presentLoginViewController");
}


@end
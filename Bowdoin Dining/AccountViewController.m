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
    /*TODO: load username & password from NSDefaults*/
    
    if(self.user == nil) {
        [self.loginButton setHidden: TRUE];
        [self performSegueWithIdentifier:@"LoginAction" sender:self];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLoad:)
                                                 name:@"UserFinishedLoading"
                                               object:nil];
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
    if(self.user != nil) {
        NSLog(@"NOT LOGGED IN");
    }
}

-(void)userDidLoad:(NSNotification *) notification {
    
    NSLog(@"User did Load");
    NSDictionary *userInfo = notification.userInfo;
    self.user = [userInfo objectForKey:@"User"];
    
    [self.loadingPoints  stopAnimating];
    [self.loadingMeals   stopAnimating];
    [self.loadingBalance stopAnimating];
    
    [self.points  setText: [NSString stringWithFormat:@"%i", self.user.polarPoints]];
    [self.meals   setText: [NSString stringWithFormat:@"%i", self.user.mealsLeft]];
    [self.balance setText: [NSString stringWithFormat:@"%i", self.user.cardBalance]];
    
    NSLog(@"Text was set");
}

- (IBAction)presentLoginViewController:(UIButton *)sender {
    NSLog(@"presentLoginViewController");
}


@end
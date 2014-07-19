//
//  AccountViewController.m
//  Bowdoin Dining
//
//  Created by Ruben on 7/16/14.
//
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "AccountViewController.h"
#import "BowdoinDining-Swift.h"

@interface AccountViewController ()
@end

//Account View Controller
@implementation AccountViewController
AppDelegate *delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //assign app delegate as delegate
    delegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //tell VC to watch for notifications from User obj
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLoad:)
                                                 name:@"UserFinishedLoading"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //show status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //[self.loginButton   setHidden: FALSE];
    
    //if user's data has not been loaded, load their data
    if(!delegate.user.dataLoaded) {
        [self reloadData:nil];
    }
}

- (IBAction)userCancelledLogin:(UIStoryboardSegue *)segue {

}

- (IBAction)userDidLogin:(UIStoryboardSegue *)segue {

}

//notification of finished user download
-(void)userDidLoad:(NSNotification *) notification {
    //update our copy of the user with new info
    NSDictionary *userInfo = notification.userInfo;
    delegate.user = [userInfo objectForKey:@"User"];
    
    //refresh onscreen info
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingData   stopAnimating];
        [self.reloadButton  setHidden: FALSE];
        [self.reloadButton  setEnabled: TRUE];
        [self.loginButton   setHidden: TRUE];
        [self.view setNeedsDisplay];
        [self.points  setText: [NSString stringWithFormat:@"$%.2f", delegate.user.polarPoints]];
        [self.meals   setText: [NSString stringWithFormat:@"%i",    delegate.user.mealsLeft]];
        [self.balance setText: [NSString stringWithFormat:@"$%.2f", delegate.user.cardBalance]];
    });
}

//reload data for user
- (IBAction)reloadData:(UIButton *)sender {
    [self.points  setText: @"N/A"];
    [self.meals   setText: @"N/A"];
    [self.balance setText: @"N/A"];
    [self.loadingData   startAnimating];
    [self.reloadButton  setHidden: TRUE];
    [self.loginButton   setHidden: TRUE];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:@"bowdoin_username"];
    NSString *password = [userDefaults objectForKey:@"bowdoin_password"];
    
    //if we have user info saved, download their data
    if(username && password) {
        dispatch_queue_t downloadQueue = dispatch_queue_create("Download queue", NULL);
        dispatch_async(downloadQueue, ^{
            //in new thread, load user info
            [delegate.user loadDataFor:username password:password];
        });
    }
    //else, ask for user credentials
    else {
        [self performSegueWithIdentifier:@"LoginModalAction" sender:self];
        [self.loginButton   setHidden: FALSE];
        [self.reloadButton  setHidden: TRUE];
        [self.loadingData   stopAnimating];
    }
}

@end
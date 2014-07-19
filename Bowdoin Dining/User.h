//
//  User.h
//  Bowdoin Dining
//
//  Created by Ruben on 7/16/14.
//
//

#import <UIKit/UIKit.h>

@interface User : NSObject

-(void)loadDataFor:(NSString *)username password:(NSString *)password;
-(void)logout;
@property (strong, atomic) NSString *username;
@property (strong, atomic) NSString *password;
@property (strong, atomic) NSString *firstname;
@property (strong, atomic) NSString *lastname;
@property double polarPoints;
@property double cardBalance;
@property int mealsLeft;
@property bool dataLoaded;


@end
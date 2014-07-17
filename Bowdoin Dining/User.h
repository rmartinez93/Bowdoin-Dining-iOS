//
//  User.h
//  Bowdoin Dining
//
//  Created by Ruben on 7/16/14.
//
//

#import <UIKit/UIKit.h>

@interface User : NSObject

-(id) initWithUsername:(NSString *) username password:(NSString *) password;
@property (strong, atomic) NSString *username;
@property (strong, atomic) NSString *password;
@property (strong, atomic) NSString *firstname;
@property (strong, atomic) NSString *lastname;
@property int polarPoints;
@property int cardBalance;
@property int mealsLeft;


@end
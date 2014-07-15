//
//  Course.m
//  Bowdoin Dining
//
//  Created by Ruben on 7/11/14.
//
//

#import "Course.h"
@interface Course ()


@end

@implementation Course

//array of all favorited items grabbed from our favorites file
+ (NSMutableArray *) allFavoritedItems {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorited = [NSMutableArray arrayWithArray: [userDefaults objectForKey:@"favorited"]];
    return favorited;
}

//add this item to the array of our favorited items and update plist
+ (void) addToFavoritedItems:(NSString *)item_id_string {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorited = [NSMutableArray arrayWithArray: [userDefaults objectForKey:@"favorited"]];
    [favorited addObject: item_id_string];
    [userDefaults setObject:favorited forKey: @"favorited"];
    [userDefaults synchronize];
}

//remove this item from the array of our favorited items and update plist
+ (void) removeFromFavoritedItems:(NSString *)item_id_string {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorited = [NSMutableArray arrayWithArray: [userDefaults objectForKey:@"favorited"]];
    [favorited removeObject: item_id_string];
    [userDefaults setObject:favorited forKey: @"favorited"];
    [userDefaults synchronize];
}
@end
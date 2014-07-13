//
//  Course.h
//  Bowdoin Dining
//
//  Created by Ruben on 7/11/14.
//
//
#import <Foundation/Foundation.h>

@interface Course : NSObject {
    // Protected instance variables (not recommended)
}

@property (strong, atomic) NSString *courseName;
@property (strong, atomic) NSMutableArray *items;
@property (strong, atomic) NSMutableArray *itemIds;
@property (strong, atomic) NSMutableArray *descriptions;

+ (void) addToFavoritedItems: (NSString *) item_id_string;
+ (void) removeFromFavoritedItems: (NSString *) item_id_string;
+ (NSMutableArray *) allFavoritedItems;

@end
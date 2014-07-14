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

+ (NSMutableArray *) allFavoritedItems {
    NSString *documentFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/favorites.plist"];
    NSMutableArray *favoritedItems;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        favoritedItems = [NSMutableArray arrayWithArray:[NSArray arrayWithContentsOfFile:filePath]];
    } else favoritedItems = [[NSMutableArray alloc] init];
    return favoritedItems;
}

+ (void) addToFavoritedItems:(NSString *)item_id_string {
    NSMutableArray *favoritedItems = [Course allFavoritedItems];
    [favoritedItems addObject: item_id_string];

    NSArray *array = [favoritedItems copy];
    
    NSString *documentFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/favorites.plist"];
    [array writeToFile:filePath atomically:YES];
}

+ (void) removeFromFavoritedItems:(NSString *)item_id_string {
    NSMutableArray *favoritedItems = [Course allFavoritedItems];
    [favoritedItems removeObject: item_id_string];
    
    NSArray *array = [favoritedItems copy];
    
    NSString *documentFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/favorites.plist"];
    [array writeToFile:filePath atomically:YES];
}
@end
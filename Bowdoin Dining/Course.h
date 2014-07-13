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
@property (strong, atomic) NSMutableArray *descriptions;

@end
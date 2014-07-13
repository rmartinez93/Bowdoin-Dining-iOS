//
//  AppDelegate.h
//  Bowdoin Dining
//
//  Created by Ruben on 7/11/14.
//
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *myProperty;
@property (strong, nonatomic) NSMutableArray *courses;
@property NSInteger day;
@property NSInteger month;
@property NSInteger year;
@property NSInteger offset;
@property NSUInteger thorneId;
@property NSUInteger moultonId;
@property NSInteger daysAdded;
@property NSInteger selectedSegment;

@end


//
//  AppDelegate.h
//  Bowdoin Dining
//
//  Created by Ruben on 7/11/14.
//
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
- (void)updateDietFilter:(NSInteger) filterIndex;
@property (strong, nonatomic) NSMutableArray *filters;
@property NSInteger day;
@property NSInteger month;
@property NSInteger year;
@property NSInteger offset;
@property NSUInteger thorneId;
@property NSUInteger moultonId;
@property NSInteger daysAdded;
@property NSInteger selectedSegment;

@end


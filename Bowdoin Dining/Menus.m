//
//  Menus.m
//  Bowdoin Dining
//
//  Created by Ruben on 7/11/14.
//
//

#import "Menus.h"
#import "Course.h"
#import "GDataXMLNode.h"

@interface Menus ()


@end

NSString *serverURL = @"http://www.bowdoin.edu/atreus/lib/xml/";
@implementation Menus
+ (NSMutableArray *)formatDate: (NSDate *) todayDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en-US"]];
    
    NSDateComponents *today = [calendar components:NSCalendarUnitYear | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday fromDate:todayDate];
    
    NSInteger offset  = [today weekday];
    
    [today setWeekday:1]; //Sunday
    NSDate *lastSundayDate = [calendar dateFromComponents:today];
    NSDateComponents *lastSunday = [calendar components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday fromDate:lastSundayDate];
    
    NSInteger day     = [lastSunday day];
    NSInteger month   = [lastSunday month]-1;
    NSInteger year    = [lastSunday year];
    
    NSMutableArray *results  = [[NSMutableArray alloc] init];
    [results addObject: [NSNumber numberWithLong:day]];
    [results addObject: [NSNumber numberWithLong:month]];
    [results addObject: [NSNumber numberWithLong:year]];
    [results addObject: [NSNumber numberWithLong:offset]];
    return results;
}

+ (NSString *)getMenuUrlForDay: (NSInteger) day Month: (NSInteger) month Year: (NSInteger) year Offset: (NSInteger) offset {
    NSString* url = [[[[serverURL
                stringByAppendingString: [NSString stringWithFormat:@"%ld",  (long)year]]
                stringByAppendingString: [NSString stringWithFormat:@"-%ld", (long)month]]
                stringByAppendingString: [NSString stringWithFormat:@"-%ld", (long)day]]
                stringByAppendingString: [NSString stringWithFormat:@"/%ld.xml", (long)offset]];
    return url;
}
+ (NSString *)getLocalPathForDay: (NSInteger) day Month: (NSInteger) month Year: (NSInteger) year Offset: (NSInteger) offset {
    NSString* local = [[[[@"local"
                stringByAppendingString: [NSString stringWithFormat:@"-%ld",  (long)year]]
                stringByAppendingString: [NSString stringWithFormat:@"-%ld", (long)month]]
                stringByAppendingString: [NSString stringWithFormat:@"-%ld", (long)day]]
                stringByAppendingString: [NSString stringWithFormat:@"-%ld.xml", (long)offset]];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* path = [[paths firstObject] stringByAppendingPathComponent:local];
    return path;
}

+ (NSData *)loadMenuForDay: (NSInteger) day Month: (NSInteger) month Year: (NSInteger) year Offset: (NSInteger) offset {
    NSString* path = [self getLocalPathForDay: day Month: month Year: year Offset: offset];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if(fileExists) {
        NSData *cached = [NSData dataWithContentsOfFile: path];
        return cached;
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSString *urlString = [self getMenuUrlForDay: day Month: month Year: year Offset: offset];
        NSURL *url = [[NSURL alloc] initWithString: urlString];
        NSError *error = nil;
        NSData *xmlData = [NSMutableData dataWithContentsOfURL: url options: 0 error: &error];
        if(error) NSLog(@"%@", [error debugDescription]);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        [xmlData writeToFile:path atomically:YES];

        return xmlData;
    }
}

+ (NSMutableArray *)createMenuFromXML:(NSData *) xmlData ForMeal: (NSUInteger) mealId AtLocation: (NSUInteger) locationId withFilters: (NSMutableArray *) filters {
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    
    GDataXMLElement *root = doc.rootElement;
    
    NSArray *meals = [root elementsForName:@"meal"];
    GDataXMLElement *meal = [meals objectAtIndex: mealId];
    
    NSArray *units = [meal elementsForName:@"unit"];
    GDataXMLElement *unit = [units objectAtIndex: locationId];
    
    GDataXMLElement *menu = [[unit elementsForName: @"menu"] firstObject];
    
    NSArray *menuItems = [menu elementsForName: @"record"];
    NSMutableArray *courses = [[NSMutableArray alloc] init];
    if(menuItems.count > 0) {
        for(GDataXMLElement *item in menuItems) {
            GDataXMLElement *courseObject = (GDataXMLElement *) [[item elementsForName: @"course"] firstObject];
            NSInteger coursePosition = -1;
            for(int i = 0; i < courses.count; i++) {
                Course *course = courses[i];
                if([course.courseName isEqualToString: courseObject.stringValue])
                    coursePosition = i;
            }
            
            GDataXMLElement *item_name = [[item elementsForName:@"formal_name"] firstObject];
            GDataXMLElement *item_id = [[item elementsForName:@"itemID"] firstObject];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\b(GF|VE|V|L)\\b" options:0 error:&error];
            NSArray *details  = [regex matchesInString:item_name.stringValue options:0 range:NSMakeRange(0, [item_name.stringValue length])];

            NSString *detail = @"";
            if(details.count) {
                for(int i = 0; i < details.count; i++) {
                    NSTextCheckingResult *special = (NSTextCheckingResult *) [details objectAtIndex:i];
                    detail = [[detail stringByAppendingString: [[item_name.stringValue
                                substringWithRange: special.range]
                                stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]]
                                stringByAppendingString:@" "];
                }
            }
            
            NSArray *attributes = [detail componentsSeparatedByString:@" "];
            
            NSString *cleaned = [[[regex stringByReplacingMatchesInString:item_name.stringValue
                                        options:0
                                        range:NSMakeRange(0, [item_name.stringValue length]) withTemplate:@""]
                                        stringByReplacingOccurrencesOfString:@"(" withString:@""]
                                        stringByReplacingOccurrencesOfString:@")" withString:@""];
            
            NSMutableSet *overlap = [NSMutableSet setWithArray:filters];
            [overlap intersectSet:[NSSet setWithArray:attributes]];
            
            if(!filters.count || [overlap allObjects].count) {
                if(coursePosition >= 0) {
                    Course *thiscourse = courses[coursePosition];
                    [thiscourse.items addObject: cleaned];
                    [thiscourse.itemIds addObject: item_id.stringValue];
                    [thiscourse.descriptions addObject: detail];
                } else {
                    Course *thiscourse = [[Course alloc] init];
                    thiscourse.courseName = courseObject.stringValue;
                    thiscourse.items = [[NSMutableArray alloc] init];
                    thiscourse.itemIds = [[NSMutableArray alloc] init];
                    thiscourse.descriptions = [[NSMutableArray alloc] init];
                    [thiscourse.items addObject: cleaned];
                    [thiscourse.itemIds addObject: item_id.stringValue];
                    [thiscourse.descriptions addObject: detail];
                    [courses addObject: thiscourse];
                }
            }
        }
    } else {
        Course *closed = [[Course alloc] init];
        closed.courseName = @"";
        closed.items = [[NSMutableArray alloc] init];
        [closed.items addObject: @"No Menu Available."];
        [courses addObject: closed];
    }
    return courses;
}

@end
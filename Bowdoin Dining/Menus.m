//
//  Menus.m
//  Bowdoin Dining
//
//  Created by Ruben on 7/11/14.
//
//

#import "Menus.h"
#import "GDataXMLNode.h"
#import "BowdoinDining-Swift.h"
@interface Menus ()


@end

NSString *serverURL = @"http://www.bowdoin.edu/atreus/lib/xml/";
@implementation Menus

//format an NSDate for our use
+ (NSMutableArray *)formatDate: (NSDate *) todayDate {
    //load gregorian calendar
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en-US"]];
    
    //create DateComponents from the NSDate and NSCalendar
    NSDateComponents *today = [calendar components:NSCalendarUnitYear | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday fromDate:todayDate];
    
    //calculate offset from sunday (day menu begins)
    NSInteger offset  = [today weekday];
    
    //set current day to sunday (first day) of this week, and create NSDateComponents for that day
    [today setWeekday:1]; //Sunday
    NSDate *lastSundayDate = [calendar dateFromComponents:today];
    NSDateComponents *lastSunday = [calendar components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday fromDate:lastSundayDate];
    
    //store info about last sunday's date for use with Bowdoin XML API
    NSInteger day     = [lastSunday day];
    NSInteger month   = [lastSunday month]-1;
    NSInteger year    = [lastSunday year];
    
    //return info in array
    NSMutableArray *results  = [[NSMutableArray alloc] init];
    [results addObject: [NSNumber numberWithLong:day]];
    [results addObject: [NSNumber numberWithLong:month]];
    [results addObject: [NSNumber numberWithLong:year]];
    [results addObject: [NSNumber numberWithLong:offset]];
    return results;
}

//create a menu url for a given day
+ (NSString *)getMenuUrlForDay: (NSInteger) day Month: (NSInteger) month Year: (NSInteger) year Offset: (NSInteger) offset {
    NSString* url = [[[[serverURL
                stringByAppendingString: [NSString stringWithFormat:@"%ld",  (long)year]]
                stringByAppendingString: [NSString stringWithFormat:@"-%ld", (long)month]]
                stringByAppendingString: [NSString stringWithFormat:@"-%ld", (long)day]]
                stringByAppendingString: [NSString stringWithFormat:@"/%ld.xml", (long)offset]];
    return url;
}

//create a local path for a given day
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

//load menu for a given day
+ (NSData *)loadMenuForDay: (NSInteger) day Month: (NSInteger) month Year: (NSInteger) year Offset: (NSInteger) offset {
    //first, search local path in case cached
    NSString* path = [self getLocalPathForDay: day Month: month Year: year Offset: offset];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if(fileExists) {
        //if cached, return cached file
        NSData *cached = [NSData dataWithContentsOfFile: path];
        return cached;
    } else { //else not cached
        //begin network activity
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        //download menu for this day
        NSString *urlString = [self getMenuUrlForDay: day Month: month Year: year Offset: offset];
        NSURL *url = [[NSURL alloc] initWithString: urlString];
        NSError *error = nil;
        NSData *xmlData = [NSMutableData dataWithContentsOfURL: url options: 0 error: &error];
        if(error) NSLog(@"%@", [error debugDescription]);

        //end network activity
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //cache file
        [xmlData writeToFile:path atomically:YES];
        
        //return downloaded file
        return xmlData;
    }
}

//creates a Menu (NSMutableArray*) from an NSData* XML file for a given meal/location and filters
+ (NSMutableArray *)createMenuFromXML:(NSData *) xmlData forMeal: (NSInteger) mealId onWeekday: (BOOL) weekday atLocation: (NSInteger) locationId withFilters: (NSMutableArray *) filters {
    NSError *error;
    //Create Google XML parsing object from NSData, grab "<meal>"s below root
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    GDataXMLElement *root = doc.rootElement;
    NSArray *meals = [root elementsForName:@"meal"];
    
    //compensates for disappearing meals
    switch (mealId) {
        case 0:
            if(!weekday) {
                mealId = 1;
            }
            break;
        case 1:
            if(weekday) {
                mealId = 2;
            } else {
                mealId = 3;
            }
            break;
        case 2:
            mealId = 3;
        default:
            break;
    }

    GDataXMLElement *meal = [meals objectAtIndex: mealId];
    
    //each meal has two units (locations), create an XML Element for this locationId's menu
    NSArray *units = [meal elementsForName:@"unit"];
    GDataXMLElement *unit = [units objectAtIndex: locationId];
    GDataXMLElement *menu = [[unit elementsForName: @"menu"] firstObject];
    
    //create array for records (menu items), initialize array of courses (a menu item attribute)
    NSArray *menuItems = [menu elementsForName: @"record"];
    NSMutableArray *courses = [[NSMutableArray alloc] init];
    
    //if there are menu items available, loop through them
    if(menuItems.count > 0) {
        for(GDataXMLElement *item in menuItems) {
            //determine course for this item and check if it already exists in our courses array
            GDataXMLElement *courseObject = (GDataXMLElement *) [[item elementsForName: @"course"] firstObject];
            NSInteger coursePosition = -1;
            for(int i = 0; i < courses.count; i++) {
                Course *course = courses[i];
                if([course.courseName isEqualToString: courseObject.stringValue])
                    coursePosition = i;
            }
            
            //grab information about this menu item: name & id
            GDataXMLElement *item_name = [[item elementsForName:@"webLongName"] firstObject];
            GDataXMLElement *item_id = [[item elementsForName:@"itemID"] firstObject];
            
            //create regex for removing diet attributes from item name, find matches in string
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\b(GF|VE|V|L)\\b" options:0 error:&error];
            NSArray *details  = [regex matchesInString:item_name.stringValue options:0 range:NSMakeRange(0, [item_name.stringValue length])];
            
            //store returned attributes into string for presentation
            NSString *detail = @"";
            if(details.count) { //if there were matches, loop through them and add them to string
                for(int i = 0; i < details.count; i++) {
                    NSTextCheckingResult *special = (NSTextCheckingResult *) [details objectAtIndex:i];
                    detail = [[detail stringByAppendingString: [[item_name.stringValue
                                substringWithRange: special.range]
                                stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]]
                                stringByAppendingString:@" "];
                }
            }
            
            //replace matches with empty space
            NSString *cleaned = [[[regex stringByReplacingMatchesInString:item_name.stringValue
                                        options:0
                                        range:NSMakeRange(0, [item_name.stringValue length]) withTemplate:@""]
                                        stringByReplacingOccurrencesOfString:@"(" withString:@""]
                                        stringByReplacingOccurrencesOfString:@")" withString:@""];
            
            //break up string of diet attributes in array for filtering
            NSArray *attributes = [detail componentsSeparatedByString:@" "];
            
            //check if diet attributes match our filter
            NSMutableSet *overlap = [NSMutableSet setWithArray:filters];
            [overlap intersectSet:[NSSet setWithArray:attributes]];
            
            //if there is no active filter, or this item passes our filter
            if(!filters.count || [overlap allObjects].count) {
                //declare this course
                Course *thiscourse;
                
                //if course already exists in our array
                if(coursePosition >= 0) {
                    //grab a copy of it, and and add this item to the course
                    thiscourse = courses[coursePosition];
                    
                    MenuItem *item = [[MenuItem alloc] init];
                    item.name = cleaned;
                    item.itemId = item_id.stringValue;
                    item.descriptors = detail;
                    
                    [thiscourse.menuItems addObject:item];
                } else { //new course, create it and add item to it
                    thiscourse = [[Course alloc] init];
                    thiscourse.courseName = courseObject.stringValue;
                    
                    MenuItem *item = [[MenuItem alloc] init];
                    item.name = cleaned;
                    item.itemId = item_id.stringValue;
                    item.descriptors = detail;
                    
                    [thiscourse.menuItems addObject:item];
                    [courses addObject: thiscourse];
                }
            }
        }
    }
    //no menu items available, add error item to courses array
    else {
        Course *closed = [[Course alloc] init];
        closed.courseName = @"";
        MenuItem *item = [[MenuItem alloc] init];
        item.name = @"No Menu Available";
        item.itemId = @"NA";
        [closed.menuItems addObject: item];
        [courses addObject: closed];
    }
    return courses; //return array of courses
}

@end
//
//  FirstViewController.m
//  Bowdoin Dining
//
//  Created by Ruben on 7/11/14.
//
//
#import "FirstViewController.h"
#import "Menus.h"
#import "Course.h"

@interface FirstViewController ()
@end

@implementation FirstViewController

NSMutableArray *courses;
NSInteger day;
NSInteger month;
NSInteger year;
NSInteger offset;
NSUInteger thorneId = 1;
NSInteger daysAdded = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.menuItems setDelegate:self];
    self.dayLabel.text = [self getTextForCurrentDay];
    
    self.meals.selectedSegmentIndex = [self segmentIndexOfCurrentMeal: [NSDate date]];
    [self updateVisibleMenu];
}

- (NSInteger)segmentIndexOfCurrentMeal:(NSDate *)now {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en-US"]];
    
    NSDateComponents *today = [calendar components: NSCalendarUnitHour | NSCalendarUnitWeekday fromDate:now];
    
    NSInteger weekday  = [today weekday];
    NSInteger hour     = [today hour];
    if(hour < 11 && weekday > 1 && weekday < 7)
        return 0;   //breakfast
    else if(hour < 14) {
        if(weekday == 1 || weekday == 7) {
            return 1; //brunch
        }
        else {
            return 2; //lunch
        }
    } else return 3;  //dinner
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return courses.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section < courses.count) {
        Course *thiscourse = [courses objectAtIndex:section];
        return thiscourse.items.count;
    } else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section < courses.count) {
        Course *thiscourse = [courses objectAtIndex:section];
        return thiscourse.courseName;
    } else return @"";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRed:0 green:0.4 blue:0.8 alpha:1]];
    header.contentView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    if(indexPath.section < courses.count && indexPath.row < [courses[indexPath.section] items].count) {
        Course *thiscourse = [courses objectAtIndex: indexPath.section];
        cell.textLabel.text = [thiscourse.items objectAtIndex: indexPath.row];
        cell.detailTextLabel.text = [thiscourse.descriptions objectAtIndex: indexPath.row];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.alpha = 0.3;
    
    [UIView beginAnimations:@"show" context:NULL];
    [UIView setAnimationDuration:0.5];
    cell.alpha = 1;
    [UIView commitAnimations];
}

- (IBAction)indexDidChangeForSegmentedControl:(UISegmentedControl *)sender {
    if (UISegmentedControlNoSegment != sender.selectedSegmentIndex) {
        [self updateVisibleMenu];
    }
}

- (void)updateVisibleMenu {
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:60*60*24*daysAdded];
    NSArray *formattedDate = [Menus formatDate: date];
    day     = [formattedDate[0] integerValue];
    month   = [formattedDate[1] integerValue];
    year    = [formattedDate[2] integerValue];
    offset  = [formattedDate[3] integerValue];
    
    NSRange originalRange = NSMakeRange(0, courses.count);
    [self.menuItems beginUpdates];
    [self.menuItems deleteSections:[NSIndexSet indexSetWithIndexesInRange:originalRange] withRowAnimation:UITableViewRowAnimationRight];
    [courses removeAllObjects];
    
    [self.meals setUserInteractionEnabled:FALSE];
    [self.loading startAnimating];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Download queue", NULL);
    dispatch_async(downloadQueue, ^{
        NSData *xml = [Menus loadMenuForDay: day Month: month Year: year Offset: offset];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (xml == nil) {
                [self.loading stopAnimating];
                [self.menuItems reloadData];
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                                  message:@"Sorry, we couldn't get the menu at this time. Check your internet connection or try again later."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                [message show];
            } else {
                courses = [Menus createMenuFromXML:xml ForMeal:[self.meals selectedSegmentIndex] AtLocation:thorneId];
                NSRange newRange = NSMakeRange(0, courses.count);
                [self.menuItems insertSections:[NSIndexSet indexSetWithIndexesInRange:newRange] withRowAnimation:UITableViewRowAnimationRight];
                [self.loading stopAnimating];
                [self.menuItems endUpdates];
                [self.menuItems setContentOffset:CGPointZero animated:YES];
                [self.meals setUserInteractionEnabled:TRUE];
            }
        });
    });
}

- (IBAction)backButtonPressed: (UIButton*)sender {
    if(daysAdded > 0) {
        daysAdded--;
        if(daysAdded == 0) {
            self.backButton.hidden = true;
        } else if(daysAdded == 5)
            self.forwardButton.hidden = false;
        [self updateVisibleMenu];
        CGFloat textWidth = [[self.dayLabel text] sizeWithAttributes:@{NSFontAttributeName:[self.dayLabel font]}].width;
        CGPoint center = self.dayLabel.center;
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^ {
                             self.dayLabel.alpha = 0.0;
                             self.dayLabel.center = CGPointMake(320+(textWidth/2), self.dayLabel.center.y);
                         }
                         completion:^(BOOL finished) {
                             self.dayLabel.text = [self getTextForCurrentDay];
                             CGFloat newWidth = [[self.dayLabel text] sizeWithAttributes:@{NSFontAttributeName:[self.dayLabel font]}].width;
                             self.dayLabel.center = CGPointMake(0-(newWidth/2), self.dayLabel.center.y);
                             [UIView animateWithDuration:0.2
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseInOut
                                              animations:^ {
                                                  self.dayLabel.center = center;
                                                  self.dayLabel.alpha = 1.0;
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                              }];
                         }];
    }
}

- (IBAction)forwardButtonPressed:(UIButton*)sender {
    if(daysAdded < 6) {
        daysAdded++;
        if(daysAdded == 6) {
            self.forwardButton.hidden = true;
        } else if(daysAdded == 1)
            self.backButton.hidden = false;
        [self updateVisibleMenu];
        CGFloat textWidth = [[self.dayLabel text] sizeWithAttributes:@{NSFontAttributeName:[self.dayLabel font]}].width;
        CGPoint center = self.dayLabel.center;
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^ {
                             self.dayLabel.alpha = 0.0;
                             self.dayLabel.center = CGPointMake(0-(textWidth/2), self.dayLabel.center.y);
                         }
                         completion:^(BOOL finished) {
                             self.dayLabel.text = [self getTextForCurrentDay];
                             CGFloat newWidth = [[self.dayLabel text] sizeWithAttributes:@{NSFontAttributeName:[self.dayLabel font]}].width;
                             self.dayLabel.center = CGPointMake(320+(newWidth/2), self.dayLabel.center.y);
                             [UIView animateWithDuration:0.2
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseInOut
                                              animations:^ {
                                                  self.dayLabel.center = center;
                                                  self.dayLabel.alpha = 1.0;
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                              }];
                         }];
    }
}

- (NSString *)getTextForCurrentDay {
    NSDate *newDate = [[NSDate date] dateByAddingTimeInterval:60*60*24*daysAdded];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    return [dateFormatter stringFromDate:newDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

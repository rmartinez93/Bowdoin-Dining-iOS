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
#import "AppDelegate.h"

@interface FirstViewController ()
@end

@implementation FirstViewController
AppDelegate *delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    delegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.menuItems setDelegate:self];
    self.meals.selectedSegmentIndex = [self segmentIndexOfCurrentMeal: [NSDate date]];
    delegate.selectedSegment = self.meals.selectedSegmentIndex;
}

- (void)viewWillAppear:(BOOL)animated {
    self.dayLabel.text = [self getTextForCurrentDay];
    self.meals.selectedSegmentIndex = delegate.selectedSegment;
    if(delegate.daysAdded == 0) {
        self.backButton.hidden = true;
    } else if(delegate.daysAdded == 6) {
        self.forwardButton.hidden = true;
    }
}

- (void)viewDidAppear:(BOOL)animated {
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
    return delegate.courses.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section < delegate.courses.count) {
        Course *thiscourse = [delegate.courses objectAtIndex:section];
        return thiscourse.items.count;
    } else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section < delegate.courses.count) {
        Course *thiscourse = [delegate.courses objectAtIndex:section];
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
    
    if(indexPath.section < delegate.courses.count && indexPath.row < [delegate.courses[indexPath.section] items].count) {
        Course *thiscourse = [delegate.courses objectAtIndex: indexPath.section];
        cell.textLabel.text = [thiscourse.items objectAtIndex: indexPath.row];
        cell.detailTextLabel.text = [thiscourse.descriptions objectAtIndex: indexPath.row];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        
        if([Course.allFavoritedItems containsObject: (NSString *)thiscourse.itemIds[indexPath.row]]) {
            cell.backgroundColor = [UIColor colorWithRed:1 green:0.84 blue:0 alpha:1];
        } else cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //1. Setup the CATransform3D structure
    CATransform3D rotation;
    rotation = CATransform3DMakeRotation( (90.0*M_PI)/180, 0.0, 0.7, 0.4);
    rotation.m34 = 1.0/ -600;
    
    //2. Define the initial state (Before the animation)
    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
    cell.layer.shadowOffset = CGSizeMake(10, 10);
    cell.alpha = 0;
    
    cell.layer.transform = rotation;
    cell.layer.anchorPoint = CGPointMake(0, 0.5);
    
    //3. Define the final state (After the animation) and commit the animation
    [UIView beginAnimations:@"rotation" context:NULL];
    [UIView setAnimationDuration:0.8];
    cell.layer.transform = CATransform3DIdentity;
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];
}

- (IBAction)indexDidChangeForSegmentedControl:(UISegmentedControl *)sender {
    if (UISegmentedControlNoSegment != sender.selectedSegmentIndex) {
        delegate.selectedSegment = self.meals.selectedSegmentIndex;
        [self updateVisibleMenu];
    }
}

- (void)updateVisibleMenu {
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:60*60*24*delegate.daysAdded];
    NSArray *formattedDate = [Menus formatDate: date];
    delegate.day     = [formattedDate[0] integerValue];
    delegate.month   = [formattedDate[1] integerValue];
    delegate.year    = [formattedDate[2] integerValue];
    delegate.offset  = [formattedDate[3] integerValue];
    
    NSRange originalRange = NSMakeRange(0, delegate.courses.count);
    [self.menuItems beginUpdates];
    [self.menuItems deleteSections:[NSIndexSet indexSetWithIndexesInRange:originalRange] withRowAnimation:UITableViewRowAnimationRight];
    [delegate.courses removeAllObjects];
    
    [self.meals setUserInteractionEnabled:FALSE];
    [self.loading startAnimating];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Download queue", NULL);
    dispatch_async(downloadQueue, ^{
        NSData *xml = [Menus loadMenuForDay: delegate.day Month: delegate.month Year: delegate.year Offset: delegate.offset];
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
                delegate.courses = [Menus createMenuFromXML:xml ForMeal:[self.meals selectedSegmentIndex] AtLocation:delegate.thorneId];
                NSRange newRange = NSMakeRange(0, delegate.courses.count);
                [self.menuItems insertSections:[NSIndexSet indexSetWithIndexesInRange:newRange] withRowAnimation:UITableViewRowAnimationRight];
                [self.loading stopAnimating];
                [self.menuItems endUpdates];
                [self.meals setUserInteractionEnabled:TRUE];
            }
        });
    });
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    Course *course = [delegate.courses objectAtIndex:indexPath.section];
    if(![Course.allFavoritedItems containsObject: (NSString *) course.itemIds[indexPath.row]]) {
        UITableViewRowAction *faveAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Favorite" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [Course addToFavoritedItems: [course.itemIds objectAtIndex:indexPath.row]];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.backgroundColor = [UIColor colorWithRed:1 green:0.84 blue:0 alpha:1];
            [tableView setEditing:NO];
        }];
        faveAction.backgroundColor = [UIColor colorWithRed:1 green:0.84 blue:0 alpha:1];
        return @[faveAction];
    } else {
        UITableViewRowAction *unfaveAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Remove" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [Course removeFromFavoritedItems: [course.itemIds objectAtIndex:indexPath.row]];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.backgroundColor = [UIColor whiteColor];
            [tableView setEditing:NO];
        }];
        unfaveAction.backgroundColor = [UIColor lightGrayColor];
        return @[unfaveAction];
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // No statement or algorithm is needed in here. Just the implementation
}

- (IBAction)backButtonPressed: (UIButton*)sender {
    if(delegate.daysAdded > 0) {
        delegate.daysAdded--;
        if(delegate.daysAdded == 0) {
            self.backButton.hidden = true;
        } else if(delegate.daysAdded == 5)
            self.forwardButton.hidden = false;
        [self updateVisibleMenu];
        CGFloat textWidth = [[self.dayLabel text] sizeWithAttributes:@{NSFontAttributeName:[self.dayLabel font]}].width;
        CGPoint center = self.dayLabel.center;
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
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
                                                 options:UIViewAnimationOptionCurveEaseIn
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
    if(delegate.daysAdded < 6) {
        delegate.daysAdded++;
        if(delegate.daysAdded == 6) {
            self.forwardButton.hidden = true;
        } else if(delegate.daysAdded == 1)
            self.backButton.hidden = false;
        CGFloat textWidth = [[self.dayLabel text] sizeWithAttributes:@{NSFontAttributeName:[self.dayLabel font]}].width;
        CGPoint center = self.dayLabel.center;
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^ {
                             self.dayLabel.alpha = 0.0;
                             self.dayLabel.center = CGPointMake(0-(textWidth/2), self.dayLabel.center.y);
                         }
                         completion:^(BOOL finished) {
                             [self updateVisibleMenu];
                             self.dayLabel.text = [self getTextForCurrentDay];
                             CGFloat newWidth = [[self.dayLabel text] sizeWithAttributes:@{NSFontAttributeName:[self.dayLabel font]}].width;
                             self.dayLabel.center = CGPointMake(320+(newWidth/2), self.dayLabel.center.y);
                             [UIView animateWithDuration:0.2
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseIn
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
    NSDate *newDate = [[NSDate date] dateByAddingTimeInterval:60*60*24*delegate.daysAdded];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    return [dateFormatter stringFromDate:newDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

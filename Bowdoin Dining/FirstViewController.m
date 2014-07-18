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
#import "SplashView.h"
#import "BowdoinDining-Swift.h"

@interface FirstViewController ()
@end

//Thorne View Controller
@implementation FirstViewController
AppDelegate *delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //show splash animation
    SplashView* splash = [[SplashView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    splash.backgroundColor = [UIColor blackColor];
    [self.view addSubview:splash];
    
    //assign app delegate as delegate
    delegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //handle UITableView display
    [self.menuItems setDelegate:self];
    
    //set selected segment to current meal on launch
    self.meals.selectedSegmentIndex = [self segmentIndexOfCurrentMeal: [NSDate date]];
    
    //style
    [self.tabBarController.tabBar setBarStyle:UIBarStyleBlack];
}

- (void)viewWillAppear:(BOOL)animated {
    //show status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    //set the text label to day we're browsing
    self.dayLabel.text = [self getTextForCurrentDay];
    
    //update selected segment in case changed elsewhere
    self.meals.selectedSegmentIndex = delegate.selectedSegment;
    
    //load menu based on delegate settings
    [self updateVisibleMenu];
        
    //verify correct buttons are showing
    [self makeCorrectButtonsVisible];
}

//calculates which meal should be selected based on an NSDate
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
}

//UITableView delegate method, returns number of sections/courses in loaded menu
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.courses.count;
}

//UITableView delegate method, returns number of rows/meal items in a given section/course
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //if this is a valid section, return number of menu items in section
    if(section < self.courses.count) {
        Course *thiscourse = [self.courses objectAtIndex:section];
        return thiscourse.items.count;
    } else return 0;
}

//UITableView delegate method, returns name of section/course
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //if this is a valid section, return name of course, else there's no title
    if(section < self.courses.count) {
        Course *thiscourse = [self.courses objectAtIndex:section];
        return thiscourse.courseName;
    } else return @"";
}

//UITableView delegate method, sets settings for cell/menu item to be displayed at a given section->row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    
    //if this is a valid section->row, grab right menu item from course and set cell properties
    if(indexPath.section < self.courses.count && indexPath.row < [self.courses[indexPath.section] items].count) {
        Course *thiscourse = [self.courses objectAtIndex: indexPath.section];
        cell.textLabel.text = [thiscourse.items objectAtIndex: indexPath.row];
        cell.detailTextLabel.text = [thiscourse.descriptions objectAtIndex: indexPath.row];
        
        //style
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        //if favorited, make item gold, else white background
        NSMutableArray *favorited = [Course allFavoritedItems];
        if([favorited containsObject: (NSString *)thiscourse.itemIds[indexPath.row]]) {
            cell.backgroundColor = [UIColor colorWithRed:1 green:0.84 blue:0 alpha:1];
        } else cell.backgroundColor = [UIColor whiteColor];
        
        //if text is too long, make cell taller
        //cell.textLabel.numberOfLines = 0;
        [cell.textLabel sizeToFit];
    }
    return cell;
}

//UITableView delegate method, what to do after side-swiping cell
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    //first, load in menu course this cell belongs to
    Course *course = [self.courses objectAtIndex:indexPath.section];
    
    //load favorited items
    NSMutableArray *favorited = [Course allFavoritedItems];
    
    //if this cell is NOT favorited, show favoriting action
    if(![favorited containsObject: (NSString *) course.itemIds[indexPath.row]]) {
        //create favoriting action
        UITableViewRowAction *faveAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Favorite" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            //if item is favorited, save it to our centralized list of favorited items
            [Course addToFavoritedItems:[course.itemIds objectAtIndex:indexPath.row]];
            
            //update styling of cell
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.backgroundColor = [UIColor colorWithRed:1 green:0.84 blue:0 alpha:1];
            [tableView setEditing:NO];
        }];
        //style of action
        faveAction.backgroundColor = [UIColor colorWithRed:1 green:0.84 blue:0 alpha:1];
        return @[faveAction];
    }
    //otherwise if this cell is favorited, show un-favoriting action
    else {
        //create unfavoriting action
        UITableViewRowAction *unfaveAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Remove" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            //if item is unfavorited, remove it from our centralized list of favorited items
            [Course removeFromFavoritedItems: [course.itemIds objectAtIndex:indexPath.row]];
            
            //update styling of cell
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.backgroundColor = [UIColor whiteColor];
            [tableView setEditing:NO];
        }];
        //style of action
        unfaveAction.backgroundColor = [UIColor lightGrayColor];
        return @[unfaveAction];
    }
}

//UITableView delegate method, needed because of bug in iOS 8 for now
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // No statement or algorithm is needed in here. Just the implementation
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

//UITableView delegate method, creates animation when displaying cell
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self animateIn: cell];
}

//UITableView delegate method, sets section header styles
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    //set style to light gray with dark blue text
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRed:0 green:0.4 blue:0.8 alpha:1]];
    header.contentView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    
    [self animateIn:header];
}

-(void)animateIn:(UIView *)view {
    //1. Setup the CATransform3D structure
    CATransform3D rotation;
    rotation = CATransform3DMakeRotation( (90.0*M_PI)/180, 0.0, 0.7, 0.4);
    rotation.m34 = 1.0/ -600;
    
    
    //2. Define the initial state (Before the animation)
    view.layer.shadowColor = [[UIColor blackColor]CGColor];
    view.layer.shadowOffset = CGSizeMake(10, 10);
    view.alpha = 0;
    
    view.layer.transform = rotation;
    view.layer.anchorPoint = CGPointMake(0, 0.5);
    
    //!!!FIX for issue #1 Cell position wrong------------
    if(view.layer.position.x != 0){
        view.layer.position = CGPointMake(0, view.layer.position.y);
    }
    
    //4. Define the final state (After the animation) and commit the animation
    [UIView beginAnimations:@"rotation" context:NULL];
    [UIView setAnimationDuration:0.8];
    view.layer.transform = CATransform3DIdentity;
    view.alpha = 1;
    view.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];
}

//user selected a different meal
- (IBAction)indexDidChangeForSegmentedControl:(UISegmentedControl *)sender {
    //if this was a valid selection, update our delegate and update the menu
    if (UISegmentedControlNoSegment != sender.selectedSegmentIndex) {
        delegate.selectedSegment = self.meals.selectedSegmentIndex;
        NSLog(@"%ld", (long)self.meals.selectedSegmentIndex);
        [self updateVisibleMenu];
    }
}

//handles all logic related to updating the tableView with new menu items
- (void)updateVisibleMenu {
    //creates date based on days added to current day, saves to delegate
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:60*60*24*delegate.daysAdded];
    NSArray *formattedDate = [Menus formatDate: date];
    delegate.day     = [formattedDate[0] integerValue];
    delegate.month   = [formattedDate[1] integerValue];
    delegate.year    = [formattedDate[2] integerValue];
    delegate.offset  = [formattedDate[3] integerValue];
    
    //firstly, remove everything from the UITableView
    NSRange originalRange = NSMakeRange(0, self.courses.count);
    [self.menuItems beginUpdates];
    [self.menuItems deleteSections:[NSIndexSet indexSetWithIndexesInRange:originalRange] withRowAnimation:UITableViewRowAnimationRight];
    [self.courses removeAllObjects];
    
    //disable user interaction on segmented control and begin loading indicator
    [self.meals setUserInteractionEnabled:FALSE];
    [self.loading startAnimating];
    
    //create a new thread...
    dispatch_queue_t downloadQueue = dispatch_queue_create("Download queue", NULL);
    dispatch_async(downloadQueue, ^{
        //in new thread, load menu for this day
        NSData *xml = [Menus loadMenuForDay: delegate.day Month: delegate.month Year: delegate.year Offset: delegate.offset];
        //go back to main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            //if the response was nil, handle
            if (!xml) {
                [self.loading stopAnimating];
                [self.menuItems reloadData];
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                                  message:@"Sorry, we couldn't get the menu at this time. Check your internet connection or try again later."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                [message show];
            }
            //else we successfully loaded XML!
            else {
                //create a menu from this data and save it to delegate
                self.courses = [Menus createMenuFromXML:xml ForMeal:[self.meals selectedSegmentIndex] AtLocation:delegate.thorneId withFilters: delegate.filters];
                //insert new menu items to UITableView
                NSRange newRange = NSMakeRange(0, self.courses.count);
                [self.menuItems insertSections:[NSIndexSet indexSetWithIndexesInRange:newRange] withRowAnimation:UITableViewRowAnimationRight];
                
                //stop loading indicator, end updates to UITableView, scroll to top and reenable user interaction
                [self.loading stopAnimating];
                [self.menuItems endUpdates];
                [self.menuItems setContentOffset:CGPointZero animated:YES];
                [self.meals setUserInteractionEnabled:TRUE];
            }
        });
    });
}

- (IBAction)backButtonPressed: (UIButton*)sender {
    if(delegate.daysAdded > 0) {
        delegate.daysAdded--;
        [self makeCorrectButtonsVisible];
        
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
                                              completion:nil];
                         }];
    }
}

- (IBAction)forwardButtonPressed:(UIButton*)sender {
    if(delegate.daysAdded < 6) {
        delegate.daysAdded++;
        [self makeCorrectButtonsVisible];
        
        [self updateVisibleMenu];
        
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
                                              completion:nil];
                         }];
    }
}

//checks to make sure back/forward buttons are only visible when appropriate
-(void)makeCorrectButtonsVisible {
    if(delegate.daysAdded == 6)
        self.forwardButton.hidden = true;
    else if(delegate.daysAdded == 0)
        self.backButton.hidden = true;
    else {
        self.backButton.hidden = false;
        self.forwardButton.hidden = false;
    }
}

//wordifies whatever day we're currently browsing
- (NSString *)getTextForCurrentDay {
    if(delegate.daysAdded == 0)
        return @"Today";
    else if(delegate.daysAdded == 1)
        return @"Tomorrow";
    else {
        NSDate *newDate = [[NSDate date] dateByAddingTimeInterval:60*60*24*delegate.daysAdded];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE"];
        return [dateFormatter stringFromDate:newDate];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

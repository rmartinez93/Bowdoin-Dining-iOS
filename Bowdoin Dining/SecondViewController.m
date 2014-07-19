//
//  FirstViewController.m
//  Bowdoin Dining
//
//  Created by Ruben on 7/11/14.
//
//
#import "SecondViewController.h"
#import "Menus.h"
#import "BowdoinDining-Swift.h"

@interface SecondViewController ()
@end

//Moulton View Controller
@implementation SecondViewController
AppDelegate *delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    delegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.menuItems setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    return self.courses.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section < self.courses.count) {
        Course *thiscourse = [self.courses objectAtIndex:section];
        return thiscourse.menuItems.count;
    } else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
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
    if(indexPath.section < self.courses.count && indexPath.row < [self.courses[indexPath.section] menuItems].count) {
        Course *thiscourse = [self.courses objectAtIndex: indexPath.section];
        MenuItem *thisitem = [thiscourse.menuItems objectAtIndex: indexPath.row];
        cell.textLabel.text       = thisitem.name;
        cell.detailTextLabel.text = thisitem.descriptors;
        
        //style
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        //if favorited, make item gold, else white background
        NSMutableArray *favorited = [Course allFavoritedItems];
        if([favorited containsObject: thisitem.itemId]) {
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
    //first, load in menuitem this cell belongs to
    Course *course = [self.courses objectAtIndex:indexPath.section];
    MenuItem *item = [course.menuItems objectAtIndex: indexPath.row];
    
    //load favorited items
    NSMutableArray *favorited = [Course allFavoritedItems];
    
    //if this cell is NOT favorited, show favoriting action
    if(![favorited containsObject: item.itemId]) {
        //create favoriting action
        UITableViewRowAction *faveAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Favorite" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            //if item is favorited, save it to our centralized list of favorited items
            [Course addToFavoritedItems:item.itemId];
            
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
            [Course removeFromFavoritedItems: item.itemId];
            
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // No statement or algorithm is needed in here. Just the implementation
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self animateIn: cell];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRed:0 green:0.4 blue:0.8 alpha:1]];
    header.contentView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    
    [self animateIn: header];
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
        
    //firstly, remove everything from the UITableView
    [self.courses removeAllObjects];
    [self.menuItems reloadData];
    
    [self.meals setUserInteractionEnabled:FALSE];
    [self.loading startAnimating];
    [self.menuItems beginUpdates];
    
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
                self.courses = [Menus createMenuFromXML:xml ForMeal:[self.meals selectedSegmentIndex] AtLocation:delegate.moultonId withFilters: delegate.filters];
                NSRange newRange = NSMakeRange(0, self.courses.count);
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
    if(delegate.daysAdded > 0) {
        delegate.daysAdded--;
        [self makeCorrectButtonsVisible];
        
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
                             [self updateVisibleMenu];
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

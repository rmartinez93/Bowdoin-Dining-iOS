//
//  FirstViewController.m
//  Bowdoin Dining
//
//  Created by Ruben on 7/11/14.
//
//
#import "SecondViewController.h"
#import "Menus.h"
#import "Course.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

NSMutableArray *courses;
NSInteger day;
NSInteger month;
NSInteger year;
NSInteger offset;
NSUInteger moultonId = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.menuItems setDelegate:self];
    NSArray *formattedDate = [Menus formatDate: [NSDate date]];
    day     = [formattedDate[0] integerValue];
    month   = [formattedDate[1] integerValue];
    year    = [formattedDate[2] integerValue];
    offset  = [formattedDate[3] integerValue];
    
    [self.meals setUserInteractionEnabled:FALSE];
    [self.loading startAnimating];
    dispatch_queue_t downloadQueue = dispatch_queue_create("Download queue", NULL);
    dispatch_async(downloadQueue, ^{
        NSData *xml = [Menus loadMenuForDay: day Month: month Year: year Offset: offset];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (xml == nil) {
                // If there was a no data received...
            } else {
                courses = [Menus createMenuFromXML:xml ForMeal:0 AtLocation:moultonId];
                [self.loading stopAnimating];
                [self.menuItems reloadData];
                [self.meals setUserInteractionEnabled:TRUE];
            }
        });
    });
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    Course *thiscourse = [courses objectAtIndex: indexPath.section];
    cell.textLabel.text = [thiscourse.items objectAtIndex: indexPath.row];
    cell.detailTextLabel.text = [thiscourse.descriptions objectAtIndex: indexPath.row];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
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
    [UIView setAnimationDuration:0.4];
    cell.layer.transform = CATransform3DIdentity;
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];
}

- (IBAction)indexDidChangeForSegmentedControl:(UISegmentedControl *)sender {
    NSUInteger index = sender.selectedSegmentIndex;
    if (UISegmentedControlNoSegment != index) {
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
                    // If there was a no data received...
                } else {
                    courses = [Menus createMenuFromXML:xml ForMeal:index AtLocation:moultonId];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

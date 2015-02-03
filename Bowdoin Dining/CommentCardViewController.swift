//
//  CommentCardViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben on 11/4/14.
//
//

import Foundation
import UIKit

class CommentCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UINavigationBarDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //UITableView delegate method, returns number of rows in a given section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    //UITableView delegate method, sets settings for cell/menu item to be displayed at a given section->row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let simpleTableIdentifier: NSString = "SimpleTableCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(simpleTableIdentifier) as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: simpleTableIdentifier)
        }
        
        cell!.textLabel!.text = ""
        cell!.textLabel!.numberOfLines = 0
        
        cell!.detailTextLabel!.text = ""
        cell!.detailTextLabel!.textColor = UIColor.lightGrayColor()

        cell!.sizeToFit()
        
        return cell!
    }
    
    //UITableView delegate method, what to do after side-swiping cell
//    func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath!) -> [AnyObject]! {
//        //first, load in menu course this cell belongs to
//        var course = self.courses[indexPath.section]
//        //get item from course
//        var item   = course.menuItems[indexPath.row]
//        
//        //load favorited items
//        var favorited = Course.allFavoritedItems()
//        
//        //if this cell is NOT favorited, show favoriting action
//        if !favorited.containsObject(item.itemId) {
//            //create favoriting action
//            var faveAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default,
//                title: "Favorite",
//                handler: {
//                    void in
//                    //if item is favorited, save it to our centralized list of favorited items
//                    Course.addToFavoritedItems(item.itemId)
//                    //update styling of cell
//                    var cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
//                    cell.backgroundColor = UIColor(red: 1, green: 0.84, blue:0, alpha:1)
//                    tableView.setEditing(false, animated: true)
//            })
//            faveAction.backgroundColor = UIColor(red:1, green:0.84, blue:0, alpha:1)
//            return [faveAction]
//        } else {
//            var unfaveAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default,
//                title: "Remove",
//                handler: {
//                    void in
//                    //otherwise if this cell is favorited, show un-favoriting action
//                    Course.removeFromFavoritedItems(item.itemId)
//                    //update styling of cell
//                    var cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
//                    cell.backgroundColor = UIColor.whiteColor()
//                    tableView.setEditing(false, animated: true)
//            })
//            unfaveAction.backgroundColor = UIColor.lightGrayColor()
//            return [unfaveAction]
//        }
//    }
    
    //UITableView delegate method, needed because of bug in iOS 8 for now
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // No statement or algorithm is needed in here. Just the implementation
    }
}
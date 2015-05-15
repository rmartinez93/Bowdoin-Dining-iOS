//
//  InterfaceController.swift
//  Dining WatchKit Extension
//
//  Created by Ruben on 4/28/15.
//
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var diningHalls : WKInterfaceTable!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        self.diningHalls.setNumberOfRows(2, withRowType: "DiningHall")
        var moulton = self.diningHalls.rowControllerAtIndex(0) as! DiningHall
        moulton.name.setText("Moulton")
        
        var thorne  = self.diningHalls.rowControllerAtIndex(1) as! DiningHall
        thorne.name.setText("Thorne")
        
        println("GO GET LINE DATA")
        WKInterfaceController.openParentApplication(["getLineData" : true], reply: { (reply, error) -> Void in
            println("AND NOW I'M BACK")
            let moultonScore = reply["moultonScore"] as! Double
            let thorneScore  = reply["thorneScore"] as! Double
            println("\(moultonScore)")
            println("\(thorneScore)")
            
            let moultonColor : UIColor?
            let thorneColor : UIColor?
            
            //first, translate thorne score to color
            if thorneScore >= 0 { //if open, parse
                if thorneScore > 0.66 { //busy line
                    thorneColor = UIColor.redColor()
                } else if thorneScore > 0.33 { //wait
                    thorneColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
                } else { //no line
                    thorneColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
                }
            } else { //else default to white
                thorneColor = UIColor.whiteColor()
            }
            
            //now translate moulton score
            if moultonScore >= 0 { //if open, parse
                if moultonScore > 0.66 { //busy line
                    moultonColor = UIColor.redColor()
                } else if moultonScore > 0.33 { //wait
                    moultonColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
                } else { //no line
                    moultonColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
                }
            } else { //else default to white
                moultonColor = UIColor.whiteColor()
            }
            
            moulton.group.setBackgroundColor(moultonColor!)
            thorne.group.setBackgroundColor(thorneColor!)
        })
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

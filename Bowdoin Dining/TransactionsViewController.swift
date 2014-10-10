//
//  TransactionsViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben on 10/9/14.
//
//

import UIKit

class TransactionsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {
    var delegate = UIApplication.sharedApplication().delegate as AppDelegate
    var transactions : [AnyObject]!
    @IBOutlet var transactionView : UITableView!
    @IBOutlet var navBar : UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        transactionView.layoutMargins = UIEdgeInsetsZero
        
        //set navbar style
        self.navBar.setBackgroundImage(UIImage(named: "bar.png"), forBarMetrics: UIBarMetrics.Default)
    }
    
    func positionForBar(bar: UIBarPositioning!) -> UIBarPosition  {
        return UIBarPosition.TopAttached
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.delegate.user!.transactions!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let simpleTableIdentifier: NSString = "SimpleTableCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(simpleTableIdentifier) as? TransactionCell
        
        if cell == nil {
            cell = NSBundle.mainBundle().loadNibNamed("TransactionCell", owner: self, options: nil).first as? TransactionCell
        }
        
        //if this is a valid section->row, grab right menu item from course and set cell properties
        var transaction = self.delegate.user!.transactions![indexPath.row] as Transaction
        cell!.titleLabel.text   = transaction.name
        cell!.dateLabel.text    = transaction.date
        cell!.amountLabel.text  = NSString(format: "-$%.2f", transaction.amount)
        cell!.balanceLabel.text = NSString(format: "$%.2f", transaction.balance)
        cell!.layoutMargins = UIEdgeInsetsZero;
        
        cell!.sizeToFit()
        
        return cell!
    }

}

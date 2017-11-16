//
//  TransactionsViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben on 10/9/14.
//
//

import UIKit

class TransactionsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {
    var delegate = UIApplication.shared.delegate as! AppDelegate
    var transactions : [AnyObject]!
    @IBOutlet var transactionView : UITableView!
    @IBOutlet var navBar : UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        transactionView.layoutMargins = UIEdgeInsets.zero
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition  {
        return UIBarPosition.topAttached
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.delegate.user!.transactions!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let simpleTableIdentifier: NSString = "SimpleTableCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: simpleTableIdentifier as String) as? TransactionCell
        
        if cell == nil {
            cell = Bundle.main.loadNibNamed("TransactionCell", owner: self, options: nil)?.first as? TransactionCell
        }
        
        //if this is a valid section->row, grab right menu item from course and set cell properties
        let transaction = self.delegate.user!.transactions![(indexPath as NSIndexPath).row] as Transaction
        cell!.titleLabel.text   = transaction.name
        cell!.dateLabel.text    = transaction.date
        cell!.amountLabel.text  = NSString(format: "-$%.2f", transaction.amount) as String
        cell!.balanceLabel.text = NSString(format: "$%.2f", transaction.balance) as String
        cell!.layoutMargins = UIEdgeInsets.zero;
        
        cell!.sizeToFit()
        
        return cell!
    }

}

//
//  UIMenuViewTableViewCell.swift
//  Bowdoin Dining
//
//  Created by Ruben on 11/13/15.
//
//

import UIKit

class UIMenuItemView: UITableViewCell {
    @IBOutlet var title : UILabel!
    @IBOutlet var detail : UILabel!
    @IBOutlet var faves : UILabel!
    @IBOutlet var icon : UIImageView!
    var favoritesCount : Int = 0
    var favorited = false
    var itemId : String?
    var delegate : UIMenuItemViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initData(favoritesCount : Int, favorited : Bool, itemId : String, delegate : UIMenuItemViewDelegate) {
        self.favoritesCount = favoritesCount
        faves.text! = favoritesCount > 0 ? "\(favoritesCount)" : ""
        
        self.favorited = favorited
        if(favorited) {
            self.icon.image = UIImage(named: "heart-filled")
        }
        
        self.itemId = itemId
        
        self.delegate = delegate
    }
    
    @IBAction func toggleFavorited() {
        favorited = !favorited
        if(favorited) {
            icon.image = UIImage(named: "heart-filled")
            favoritesCount++
        }
        else {
            icon.image = UIImage(named: "heart")
            favoritesCount--
        }
        
        faves.text! = favoritesCount > 0 ? "\(favoritesCount)" : ""
        
        delegate?.toggleFavorite(self.itemId!)
    }
}

protocol UIMenuItemViewDelegate {
    func toggleFavorite(itemId : String)
}
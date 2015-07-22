//
//  ResultCell.swift
//  Scanner
//
//  Created by Maxence Ho on 22/07/2015.
//  Copyright (c) 2015 Maxence Ho. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {
    
    // MARK: - Instance variable
    @IBOutlet weak var iconView:    UIImageView!
    @IBOutlet weak var iPValue:     UILabel!
    @IBOutlet weak var portNumber:  UILabel!
    
    class var reuseIdentifier: String {
        get {
            return "ResultCell"
        }
    }
   
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
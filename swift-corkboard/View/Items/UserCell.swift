//
//  UserCell.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 10/4/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    var usersId : String = ""
    
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var userName: UILabel!
    
    @IBAction func removeUser(_ sender: UIButton) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

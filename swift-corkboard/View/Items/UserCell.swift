//
//  UserCell.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 10/4/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit

protocol UserCellDelegate: AnyObject {
    func removeButton(cell: UserCell)
}

class UserCell: UITableViewCell {

    @IBOutlet var removeButton: UIButton!
    weak var delegate: UserCellDelegate?
    
    var usersId : String = ""
    
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var userName: UILabel!
    
    @IBAction func removeUser(_ sender: UIButton) {
        delegate?.removeButton(cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

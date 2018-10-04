//
//  WebpageCell.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 9/17/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit

class WebpageCell: UICollectionViewCell {

    @IBOutlet var img: UIImageView!
    @IBOutlet var info: UITextView!
    
    @IBOutlet var userPhoto: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        img.layer.cornerRadius = 15
    }
    
    var webpageId : String = ""
    
    var webpageUrl : String = ""

}

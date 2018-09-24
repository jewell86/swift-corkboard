//
//  WebpageCell.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 9/17/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit

class WebpageCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var webpageId : String = ""
    
    var webpageUrl : String = ""
    
    @IBOutlet var img: UIImageView!
    
    @IBOutlet var imageTitle: UILabel!
    
    let url = URL(string: "\(webpageUrl)") {
        UIApplication.shared.open(url, options: [:])
    }
}

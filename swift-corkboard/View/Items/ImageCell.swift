//
//  ImageCell.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 9/17/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit
import Alamofire

class ImageCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var imageId : String = ""

    @IBOutlet var img: UIImageView!
    
    @IBOutlet var imageTitle: UITextView!
    
    @IBAction func saveImageTitle(_ sender: UIButton) {
        let url = "http://localhost:5000/updateItem"
        Alamofire.request(url, method: .patch, parameters: ["content": self.imageTitle.text!, "id": self.imageId], encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success:
                print("Succeeded")
            case .failure(let error):
                print(error)
            }
        }
        print("hello")
//        BoardViewController().renderItems()
    }
    
    

    
    

}

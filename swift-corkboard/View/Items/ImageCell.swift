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

    }
    
    var imageId : String = ""

    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var img: UIImageView!
    @IBOutlet var imageTitle: UITextView!
    
    @IBAction func saveImageTitle(_ sender: UIButton) {
        let url = "https://powerful-earth-36700.herokuapp.com/updateItem"
        Alamofire.request(url, method: .patch, parameters: ["content": self.imageTitle.text!, "id": self.imageId], encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success:
                print("Succeeded")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    

    
    

}

//
//  MapViewCell.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 9/26/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewCell: UICollectionViewCell, GMSMapViewDelegate {
    
    @IBOutlet var myMapView: GMSMapView!
    

    @IBOutlet var mapTitle: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        myMapView.frame = CGRect(x: 0, y: 0, width: 120, height: 100)

    }
}
    

    
    
    
    


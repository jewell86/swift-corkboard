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
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        let camera = GMSCameraPosition.camera(withLatitude: +31.75097946, longitude: +35.23694368, zoom: 6.0)
//        self.myMapView.camera = camera
//        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//        mapView.isMyLocationEnabled = true
//        mapView.mapType =  .terrain

        // CHANGE THIS
//        self.myMapView = mapView

        myMapView.frame = CGRect(x: 0, y: 0, width: 120, height: 120)

        // Creates a marker in the center of the map.
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: +31.75097946, longitude: +35.23694368)
//        marker.title = "my location"
//        marker.map = mapView

    }
}
    
//    var mapId : String = ""
    
    
    
    


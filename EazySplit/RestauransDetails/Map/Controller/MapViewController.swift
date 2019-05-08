//
//  MapViewController.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 01/05/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    var restaurant: Restaurant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        if let restaurant = restaurant {
            let camera = GMSCameraPosition.camera(withLatitude: restaurant.latitude, longitude: restaurant.longitude, zoom: 16.0)
            let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            view = mapView
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
            marker.title = restaurant.name
            marker.snippet = restaurant.address
            marker.map = mapView
        }
    }

}

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

    var restaurants: [Restaurant]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {

        let mapView = GMSMapView(frame: CGRect.zero)
        self.view = mapView

        FirebaseService.shared.listRestaurants { (result, restaurants) in
            switch result {
            case .success:
                if let restaurants = restaurants {
                    var bounds = GMSCoordinateBounds()
                    for restaurant in restaurants {

                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude: restaurant.latitude,
                                                                 longitude: restaurant.longitude)
                        marker.title = restaurant.name
                        marker.snippet = restaurant.address
                        marker.map = mapView
                        bounds = bounds.includingCoordinate(marker.position)
                    }

                    let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
                    mapView.animate(with: update)
                }
            case .error(let error):
                Loader.shared.hideOverlayView()
                print(error)
            }
        }
    }

}

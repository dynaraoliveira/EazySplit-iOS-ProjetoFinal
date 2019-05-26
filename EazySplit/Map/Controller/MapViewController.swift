//  MapViewController.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 01/05/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit


class MapViewController: UIViewController , CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var restaurants: [Restaurant]?
    var locationManager =  CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func loadView() {
        
        let mapView = GMSMapView(frame: CGRect.zero)
        self.view = mapView
        
        FirebaseService.shared.listRestaurants { (result, restaurants) in
            switch result {
            case .success:
                if let restaurants = restaurants {
                    var bounds = GMSCoordinateBounds()
                    let restaurant = restaurants[0]
                    let marker = GMSMarker()
                    
                    marker.position = CLLocationCoordinate2D(latitude: restaurant.latitude,
                                                             longitude: restaurant.longitude)
                    marker.title = restaurant.name
                    marker.snippet = restaurant.address
                    marker.map = mapView
                    
                    bounds = bounds.includingCoordinate(marker.position)
                    mapView.isMyLocationEnabled = true
                    
                    let path = GMSMutablePath()
                    path.addLatitude(restaurant.latitude, longitude: restaurant.longitude)
                    if let location: CLLocation = self.locationManager.location {
                        let coordinate: CLLocationCoordinate2D = location.coordinate
                        path.add(coordinate)
                        bounds = bounds.includingCoordinate(coordinate)
                    }
                    
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeWidth = 5.0
                    polyline.geodesic = true
                    polyline.map = mapView
                
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



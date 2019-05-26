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
    var mylocation =  CLLocationManager()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       mylocation.delegate = self
       mylocation.desiredAccuracy = kCLLocationAccuracyBest
       mylocation.requestWhenInUseAuthorization()

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
                        mapView.isMyLocationEnabled = true
                      //  mapView.add(marke, level: .aboveRoads)
                      
                       
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
    /*
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        
        return nil
    } */
    

}



//
//  RestaurantDetailsViewController.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 01/05/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import UIKit

class RestaurantDetailsViewController: UIViewController {

    var restaurant: Restaurant?
    
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let restaurant = restaurant {
            restaurantImageView.loadImage(withURL: restaurant.urlImage)
            restaurantNameLabel.text = restaurant.name
            let rating = restaurant.rating / 2
            ratingLabel.text = "Rating " + "⭐️".replicate(withNumber: rating)
            typeLabel.text = restaurant.type
            descriptionLabel.text = restaurant.description
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let embedVC = segue.destination as? MapViewController {
            embedVC.restaurant = restaurant
        }
    }
    
}

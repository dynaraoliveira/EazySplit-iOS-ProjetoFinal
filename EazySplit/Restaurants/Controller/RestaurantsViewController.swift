//
//  RestaurantsViewController.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 21/04/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import UIKit
import FirebaseAuth

class RestaurantsViewController: UIViewController {

    @IBOutlet weak var restaurantsTableView: UITableView!
    
    var restaurants: [Restaurant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRestaurants()
        restaurantsTableView.delegate = self
        restaurantsTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNavigationBar()
        tabBarController?.tabBar.isHidden = false
    }
    
    private func loadRestaurants() {
        Loader.shared.showOverlay(view: self.view)
        
        FirebaseService.shared.listRestaurants { (result, restaurants) in
            Loader.shared.hideOverlayView()
            switch result {
            case .success:
                if let restaurants = restaurants {
                    self.restaurants = restaurants
                    self.restaurantsTableView.reloadData()
                }
            case .error(let error):
                print(error)
            }
        }
    }
}

extension RestaurantsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let restaurant = restaurants[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantTableViewCell") as? RestaurantTableViewCell else {
                return UITableViewCell()
        }
        
        cell.setupRestaurant(restaurant)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restaurant = restaurants[indexPath.row]
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyBoard
            .instantiateViewController(withIdentifier:"RestaurantDetailsViewController") as? RestaurantDetailsViewController else { return }
        vc.restaurant = restaurant
        tabBarController?.tabBar.isHidden = true
        pushViewController(vc)
    }
    
}

extension RestaurantsViewController {
    private func loadNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        
        let size = navigationController?.navigationBar.frame.height ?? 0.0
        
        let btnProfile = UIButton(type: .custom)
        
        if let withURL = Auth.auth().currentUser?.photoURL,
            let data = try? Data(contentsOf: withURL),
            let image = UIImage(data: data) {
            btnProfile.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            btnProfile.setImage(UIImage (named: "foto")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        btnProfile.frame = CGRect(x: 0.0, y: 0.0, width: size, height: size)
        btnProfile.widthAnchor.constraint(equalToConstant: size).isActive = true
        btnProfile.heightAnchor.constraint(equalToConstant: size).isActive = true
        btnProfile.layer.cornerRadius = size / 2
        btnProfile.layer.masksToBounds = true
        let btnProfileItem = UIBarButtonItem(customView: btnProfile)
        self.navigationItem.rightBarButtonItems = [btnProfileItem]
    }
}

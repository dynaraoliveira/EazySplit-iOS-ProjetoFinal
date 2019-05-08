//
//  SettingViewController.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 30/04/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingViewController: UIViewController {

    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var nameProfile: UILabel!
    @IBOutlet weak var meansOfPayment: UIButton!
    @IBOutlet weak var language: UIButton!
    @IBOutlet weak var about: UIButton!
    @IBOutlet weak var logout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        
        if let urlImage = Auth.auth().currentUser?.photoURL {
            imageProfile.loadImage(withURL: urlImage)
        }
        
        if let name = Auth.auth().currentUser?.displayName {
            nameProfile.text = name
        }
        
        imageProfile.layer.cornerRadius = imageProfile.frame.height / 2.0
        imageProfile.layer.masksToBounds = true
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction func editProfile(_ sender: Any) {
        goToViewController(withIdentifier: "RegisterViewController")
    }
    
    @IBAction func clickMeansOfPayment(_ sender: Any) {
        goToViewController(withIdentifier: "MeansOfPaymentTableViewController")
    }
    
    @IBAction func clickLanguage(_ sender: Any) {
    }
    
    @IBAction func clickAbout(_ sender: Any) {
        goToViewController(withIdentifier: "AboutViewController")
    }
    
    
    @IBAction func clickLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        } catch(let error) {
            print(error)
        }
        
    }
}

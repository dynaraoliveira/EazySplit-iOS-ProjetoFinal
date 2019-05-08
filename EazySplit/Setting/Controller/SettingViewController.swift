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

    @IBOutlet weak var language: UIButton!
    @IBOutlet weak var logout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func clickLanguage(_ sender: Any) {
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

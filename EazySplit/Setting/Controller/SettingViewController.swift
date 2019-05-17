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

    
    @IBOutlet weak var touchId: UISwitch!
    @IBOutlet weak var logout: UIButton!
    
    var userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        touchId.isOn = userDefaults.bool(forKey: "touchid")
    }
    
    @IBAction func changeSwitch(_ sender: Any) {
        if !userDefaults.bool(forKey: "touchid") {
            userDefaults.set(true, forKey: "touchid")
        } else {
            userDefaults.set(false, forKey: "touchid")
        }

        userDefaults.synchronize()
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

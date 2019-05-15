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
    
    let APPLE_LANGUAGE_KEY = "AppleLanguages"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func clickLanguage(_ sender: Any) {
        if currentAppleLanguage() == "en" {
            setAppleLAnguageTo(lang: "pt-BR")
        } else {
            setAppleLAnguageTo(lang: "en")
        }
    }
    
    @IBAction func clickLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        } catch(let error) {
            print(error)
        }
        
    }
    
    private func currentAppleLanguage() -> String{
        let userdef = UserDefaults.standard
        let langArray = userdef.object(forKey: APPLE_LANGUAGE_KEY) as! NSArray
        let current = langArray.firstObject as! String
        return current
    }
    
    private func setAppleLAnguageTo(lang: String) {
        let userdef = UserDefaults.standard
        userdef.set([lang,currentAppleLanguage()], forKey: APPLE_LANGUAGE_KEY)
        userdef.synchronize()
    }
}

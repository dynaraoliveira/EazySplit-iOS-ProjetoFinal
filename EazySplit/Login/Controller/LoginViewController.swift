//
//  LoginViewController.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 21/04/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import UIKit
import FirebaseAuth
import LocalAuthentication

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var firebaseService: FirebaseService?
    var userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButton()
        
        if userDefaults.bool(forKey: "touchid") {
            authId()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        if Auth.auth().currentUser != nil {
            goToHomeTabBar()
        }
    }
    
    private func setButton() {
        loginButton.loadCornerRadius()
    }
    
    @IBAction func loginClick(_ sender: Any) {
        Loader.shared.showOverlay(view: self.view)
        
        Auth.auth().signIn(withEmail: userTextField.text ?? "", password: passwordTextField.text ?? "") { (result, error) in
            Loader.shared.hideOverlayView()
            if error != nil {
                self.alertInvalidLogin()
                return
            } else {
                self.userDefaults.set(self.userTextField.text ?? "", forKey: "user-email")
                self.userDefaults.set(self.passwordTextField.text ?? "", forKey: "user-password")
                self.userDefaults.synchronize()
                self.goToHomeTabBar()
            }
        }
    }
    
    private func alertInvalidLogin() {
        let alert = UIAlertController(title: "Login", message: "Invalid login or password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func goToHomeTabBar() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyBoard
            .instantiateViewController(withIdentifier:"HomeTabBar") as? UITabBarController else { return }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    private func authId() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        self.goToHomeTabBar()
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "Sorry!", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    private func authUser(email: String, password: String) {
        Loader.shared.showOverlay(view: self.view)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            Loader.shared.hideOverlayView()
            if error != nil {
                self.alertInvalidLogin()
                return
            } else {
                if !self.userDefaults.bool(forKey: "touchid") {
                    self.synchronizeUserDefaults()
                }
                self.goToHomeTabBar()
            }
        }
    }
    
    private func synchronizeUserDefaults() {
        userDefaults.set(self.userTextField.text ?? "", forKey: "user-email")
        userDefaults.set(self.passwordTextField.text ?? "", forKey: "user-password")
        userDefaults.synchronize()
    }
}


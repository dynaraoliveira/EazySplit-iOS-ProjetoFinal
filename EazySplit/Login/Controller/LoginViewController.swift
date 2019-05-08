//
//  LoginViewController.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 21/04/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var firebaseService: FirebaseService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButton()
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
    
}


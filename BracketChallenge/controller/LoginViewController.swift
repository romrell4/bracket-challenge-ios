//
//  ViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

class LoginViewController: UIViewController, LoginButtonDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = LoginButton(readPermissions: [.publicProfile, .email])
        loginButton.center = view.center
        loginButton.delegate = self
        view.addSubview(loginButton)
        
        checkForLogin()
    }
    
    //MARK: Listeners
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        print("Logged in")
        checkForLogin()
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("Logged out")
    }
    
    //MARK: Private Functions
    
    private func checkForLogin() {
        if AccessToken.current != nil {
            performSegue(withIdentifier: "loggedIn", sender: nil)
        }
    }
}


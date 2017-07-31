//
//  ViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import FacebookLogin
import FacebookCore

class LoginViewController: BCViewController, LoginButtonDelegate {
    
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createFacebookLoginButton()
        
        checkForLogin()
    }
    
    //MARK: Listeners
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        checkForLogin()
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("Logged out")
    }
    
    //MARK: Private Functions
    
    private func createFacebookLoginButton() {
        let loginButton = LoginButton(readPermissions: [.publicProfile, .email])
        loginButton.center = view.center
        loginButton.delegate = self
        view.addSubview(loginButton)
    }
    
    private func checkForLogin() {
        if AccessToken.current != nil {
            GraphRequest(graphPath: "me", parameters: ["fields": "first_name,email, picture.type(large)"]).start { (_, result) in
                switch result {
                case .success(let response):
                    let dict = response.dictionaryValue
                    if let email = dict?["email"] as? String {
                        BCClient.login(username: email, callback: { (user, error) in
                            if user != nil {
                                self.performSegue(withIdentifier: "loggedIn", sender: nil)
                            } else {
                                super.displayAlert(error: error)
                            }
                        })
                    }
                case .failed(let error):
                    super.displayAlert(error: BCError(error: error))
                }
            }

        }
    }
}


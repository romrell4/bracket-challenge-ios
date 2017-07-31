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
    
    //MARK: Properties
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createFacebookLoginButton()
        
        checkForLogin()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loggedIn", let navVc = segue.destination as? UINavigationController, let vc = navVc.viewControllers[0] as? TournamentsViewController, let user = user {
            vc.user = user
        }
    }
    
    //MARK: LoginButtonDelegate callbacks
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        checkForLogin()
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("Logged out")
    }
    
    //MARK: Private Functions
    
    private func createFacebookLoginButton() {
        let loginButton = LoginButton(readPermissions: [.publicProfile, .email])
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.delegate = self
        view.addSubview(loginButton)
        view.addConstraints([
            NSLayoutConstraint(item: view, attr1: .centerX, toItem: loginButton, attr2: .centerX),
            NSLayoutConstraint(item: view, attr1: .centerY, toItem: loginButton, attr2: .centerY)
        ])
    }
    
    private func checkForLogin() {
        if AccessToken.current != nil {
            BCClient.login(callback: { (user, error) in
                if let user = user {
                    self.user = user
                    self.performSegue(withIdentifier: "loggedIn", sender: nil)
                } else {
                    super.displayAlert(error: error)
                }
            })
        }
    }
}


//
//  ViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import FacebookLogin
import FacebookCore

class LoginViewController: UIViewController, LoginButtonDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    //MARK: Properties
    private var loginButton: LoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createFacebookLoginButton()
		
		checkForLogin()
    }
	
	@IBAction func unwindSegue(_ sender: UIStoryboardSegue) {
		LoginManager().logOut()
		checkForLogin()
	}
    
    //MARK: LoginButtonDelegate callbacks
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        //When we get notified of a change, try to login with their token
        checkForLogin()
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {}
    
    //MARK: Private Functions
    
    private func createFacebookLoginButton() {
        //Throw a login button into the middle of the screen and make ourselves a delegate
        loginButton = LoginButton(readPermissions: [.publicProfile, .email])
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
            print(AccessToken.current!)
            loginButton.isHidden = true
            
            //Try to log in. No need to pass anything in, the token identifies the user
            spinner.startAnimating()
            BCClient.login(callback: { (user, error) in
                self.spinner.stopAnimating()
                if let user = user {
                    //Set the user in a static context. This will make it accessible from everywhere
                    Identity.user = user
                    self.performSegue(withIdentifier: "loggedIn", sender: nil)
                } else {
                    super.displayAlert(error: error)
                }
            })
        } else {
            loginButton.isHidden = false
        }
    }
}


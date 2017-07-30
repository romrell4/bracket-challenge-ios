//
//  ViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit
import FacebookLogin

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let facebookLoginButton = LoginButton(readPermissions: [.publicProfile, .email])
        facebookLoginButton.center = view.center
        
        view.addSubview(facebookLoginButton)
    }
}


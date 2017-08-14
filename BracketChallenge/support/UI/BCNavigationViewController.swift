//
//  BCNavigationViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/31/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class BCNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor.bcGreen
        navigationBar.tintColor = UIColor.bcYellow
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white];
        
        //Don't allow the user to swipe back (it messes with the scroll view)
        interactivePopGestureRecognizer?.isEnabled = false
    }
}

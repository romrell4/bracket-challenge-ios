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

        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = UIColor.bcGreen
        self.navigationBar.tintColor = UIColor.bcYellow
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white];
    }
}

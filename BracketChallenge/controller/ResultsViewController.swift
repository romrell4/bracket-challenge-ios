//
//  ResultsViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/6/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class ResultsViewController: BracketViewController {
    
    override func viewDidDisappear(_ animated: Bool) {
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
	
	override func areCellsClickable() -> Bool {
		return Identity.user.admin
	}
}

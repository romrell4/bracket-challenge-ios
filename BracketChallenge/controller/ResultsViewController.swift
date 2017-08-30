//
//  ResultsViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/6/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class ResultsViewController: BracketViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        //If the user is an admin, they can edit the results
        if Identity.user.admin {
            tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateBracket))
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    //Listeners
    
    override func areCellsClickable() -> Bool {
        //Results are only editable by admins
        return Identity.user.admin
    }
}

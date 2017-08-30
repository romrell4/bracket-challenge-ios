//
//  ResultsViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/6/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class ResultsViewController: BracketViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO: Don't reload this. Just pass it in from the MyBracketVC
        if let bracketId = super.tournament.masterBracketId {
            super.loadBracket(bracketId: bracketId)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Identity.user.admin {
            tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateBracket))
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    //Listeners
    
    override func areCellsClickable() -> Bool {
        return Identity.user.admin
    }
}

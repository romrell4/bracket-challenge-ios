//
//  ResultsViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/6/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

class ResultsViewController: BracketViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let bracketId = super.tournament.masterBracketId {
            super.loadBracket(bracketId: bracketId)
        }
    }
    
    override func areCellsClickable() -> Bool {
        return Identity.user.admin
    }
}

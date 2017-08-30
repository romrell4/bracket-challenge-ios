//
//  UserBracketViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/28/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class UserBracketViewController: BracketViewController {
    
    //Public properties
    var userBracket: Bracket!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Do this without loading the bracket
        super.loadBracket(bracketId: userBracket.bracketId)
    }
    
    override func areCellsClickable() -> Bool {
        return false
    }
}

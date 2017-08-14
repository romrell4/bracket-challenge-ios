//
//  MyBracketViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/6/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class MyBracketViewController: BracketViewController {
    //MARK: Outlets
    @IBOutlet weak var createBracketView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BCClient.getMyBrackets(tournamentId: super.tournament.tournamentId, callback: { (brackets, error) in
            if let brackets = brackets {
                //If they have a bracket, pass the bracketId in to the MyBracketVC
                if brackets.count != 0 {
                    //For now, just load up their first. We'll decide later if we want to add multiple brackets
                    let myBracket = brackets[0]
                    //TODO: Make this not have to reload the bracket again
                    super.loadBracket(bracketId: myBracket.bracketId)
                } else {
                    super.spinner.stopAnimating()
                    self.createBracketView.isHidden = false
                    self.view.bringSubview(toFront: self.createBracketView)
                }
            } else {
                super.displayAlert(error: error)
            }
        })
    }
    
    //MARK: Listeners
    
    @IBAction func createBracketTapped(_ sender: Any) {
        super.spinner.startAnimating()
        BCClient.createBracket(tournamentId: super.tournament.tournamentId) { (bracket, error) in
            super.spinner.stopAnimating()
            self.createBracketView.isHidden = true
            if let bracket = bracket {
                super.bracket = bracket
                super.setupCollectionViews()
            } else {
                super.displayAlert(error: error)
            }
        }
    }
}

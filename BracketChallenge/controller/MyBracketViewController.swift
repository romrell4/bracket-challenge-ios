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
        
        BCClient.getMyBracket(tournamentId: super.tournament.tournamentId, callback: { (validResponse, bracket, error) in
            super.spinner.stopAnimating()
            if validResponse {
                if let bracket = bracket {
                    super.bracket = bracket
                } else {
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
            } else {
                super.displayAlert(error: error)
            }
        }
    }
}

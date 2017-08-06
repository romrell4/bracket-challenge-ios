//
//  TournamentTabBarViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/3/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class TournamentTabBarViewController: UITabBarController {
    
    //Public properties
    var tournament: Tournament!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = tournament.name
        if let myBracketVc = viewControllers?[0] as? BracketViewController {
            let tournamentId = tournament.tournamentId
            myBracketVc.tournamentId = tournamentId
            BCClient.getMyBrackets(tournamentId: tournamentId, callback: { (brackets, error) in
                if let brackets = brackets {
                    //If they have a bracket, pass the bracketId in to the MyBracketVC
                    if brackets.count != 0 {
                        //For now, just load up their first. We'll decide later if we want to add multiple brackets
                        myBracketVc.bracketId = brackets[0].bracketId
                    }
                } else {
                    myBracketVc.displayAlert(error: error)
                }
            })
        }
        if let resultsVc = viewControllers?[1] as? BracketViewController {
            resultsVc.tournamentId = tournament.tournamentId
            resultsVc.bracketId = tournament.masterBracketId
        }
//        if let standingsVc = viewControllers?[2] as? StandingsViewController {
//            standingsVc.tournamentId = tournament.tournamentId
//        }
    }
}

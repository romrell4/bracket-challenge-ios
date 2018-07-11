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
        
        self.tabBar.isTranslucent = false
        
        if let myBracketVc = viewControllers?[0] as? MyBracketViewController {
            myBracketVc.tournament = tournament
        }
        if let resultsVc = viewControllers?[1] as? ResultsViewController {
            resultsVc.tournament = tournament
        }
        if let standingsVc = viewControllers?[2] as? StandingsViewController {
            standingsVc.tournament = tournament
        }
		if let testVc = viewControllers?[3] as? BracketViewController2 {
			testVc.tournament = tournament
		}
    }
}

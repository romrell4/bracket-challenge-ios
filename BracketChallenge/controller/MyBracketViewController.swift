//
//  MyBracketViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/6/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class MyBracketViewController: UserBracketViewController, UITabBarControllerDelegate {
    //MARK: Outlets
    @IBOutlet private weak var createBracketView: UIView!
	@IBOutlet private weak var createBracketLabel: UILabel!
	@IBOutlet private weak var createBracketButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This will let us choose when the tab bar can be selected, and what to do on selection
        tabBarController?.delegate = self
        
        loadData()
		
		if !tournament.active {
			createBracketLabel.text = "This tournament has already started. No new brackets are being taken."
			createBracketButton.isHidden = true
		}
    }
    
    override func viewDidAppear(_ animated: Bool) {
		if tournament.active {
			//Add the save button when this tab is selected
			tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateBracket))
		}
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //Remove the save button when a different tab is selected
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    //MARK: UITabBarController callbacks
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        //Let the user change tabs AFTER the data is loaded
        return (super.userBracket != nil || !self.createBracketView.isHidden) && masterBracket != nil
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //Whichever tab they select, pass in the master bracket (so that they don't have to load it themselves)
        if let vc = viewController as? ResultsViewController, vc.bracket == nil {
            vc.bracket = masterBracket
        } else if let vc = viewController as? StandingsViewController, vc.masterBracket == nil {
            vc.masterBracket = masterBracket
		} else if let vc = viewController as? BracketViewController2, vc.bracket == nil {
			vc.bracket = masterBracket /*Bracket(rounds: [
				[
					MatchHelper(round: 1, position: 1, player1Id: 1, player1Name: "Test 1", player2Id: 2, player2Name: "Test 2", winnerId: 1),
					MatchHelper(round: 1, position: 2, player1Id: 3, player1Name: "Test 3", player2Id: 4, player2Name: "Test 4", winnerId: 4)
				],
				[
					MatchHelper(round: 2, position: 1, player1Id: 1, player1Name: "Test 1", player2Id: 4, player2Name: "Test 4", winnerId: 1)
				]
			])*/
		}
    }
    
    //MARK: Listeners
    
    override func areCellsClickable() -> Bool {
        //They should only be able to edit their picks if the tournament hasn't started yet
        return tournament.active
    }
    
    @IBAction func createBracketTapped(_ sender: Any) {
        super.spinner.startAnimating()
        BCClient.createBracket(tournamentId: super.tournament.tournamentId, bracketName: Identity.user.name) { (bracket, error) in
            super.spinner.stopAnimating()
            if let bracket = bracket {
                //When the bracket is successfully created, hide the view
                self.createBracketView.isHidden = true
                super.userBracket = bracket
            } else {
                super.displayAlert(error: error)
            }
        }
    }
    
    //MARK: Private functions
    
    private func loadData() {
        guard let masterBracketId = super.tournament.masterBracketId else {
            //They should not be here if there is no master bracket yet
            super.popBack()
            return
        }
        
        super.spinner.startAnimating()
        
        //Load the user's bracket
        BCClient.getMyBracket(tournamentId: super.tournament.tournamentId, callback: { (validResponse, bracket, error) in
            if validResponse {
                if let bracket = bracket {
                    super.userBracket = bracket
                } else {
                    //If they don't have a bracket yet, show the create bracket view
                    self.createBracketView.isHidden = false
                    self.view.bringSubview(toFront: self.createBracketView)
                }
            } else {
                super.displayAlert(error: error)
            }
        })
        
        //Load the master bracket
        BCClient.getBracket(tournamentId: super.tournament.tournamentId, bracketId: masterBracketId) { (masterBracket, error) in
            if let masterBracket = masterBracket {
                self.masterBracket = masterBracket
            } else {
                super.displayAlert(error: error)
            }
        }
    }
}

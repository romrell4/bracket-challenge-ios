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
		
		if !areCellsClickable() {
			createBracketLabel.text = "This tournament has already started. No new brackets are being taken."
			createBracketButton.isHidden = true
		}
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //Remove the save button when a different tab is selected
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    //MARK: UITabBarController callbacks
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        //Let the user change tabs AFTER the data is loaded
        return (super.bracket != nil || !self.createBracketView.isHidden) && masterBracket != nil
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //Whichever tab they select, pass in the master bracket (so that they don't have to load it themselves)
        if let vc = viewController as? ResultsViewController, vc.bracket == nil {
            vc.bracket = masterBracket
        } else if let vc = viewController as? StandingsViewController, vc.masterBracket == nil {
            vc.masterBracket = masterBracket
		}
    }
    
    //MARK: Listeners
    
    override func areCellsClickable() -> Bool {
        //They should only be able to edit their picks if the tournament hasn't started yet (or if they're an admin)
        return tournament.active || Identity.user?.admin == true
    }
    
    @IBAction func createBracketTapped(_ sender: Any) {
		guard let user = Identity.user else { return }
        super.spinner.startAnimating()
        BCClient.createBracket(tournamentId: super.tournament.tournamentId, bracketName: user.name) { (bracket, error) in
            super.spinner.stopAnimating()
            if let bracket = bracket {
                //When the bracket is successfully created, hide the view
                self.createBracketView.isHidden = true
                super.bracket = bracket
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
        
        //Load the user's bracket
        BCClient.getMyBracket(tournamentId: super.tournament.tournamentId, callback: { (validResponse, bracket, error) in
            if validResponse {
				//Set temp variable, which will eventually set the parent's bracket, or show the create bracket view
				self.tmpBracket = bracket
            } else {
                super.displayAlert(error: error)
            }
        })
        
        //Load the master bracket
        BCClient.getBracket(tournamentId: super.tournament.tournamentId, bracketId: masterBracketId) { (masterBracket, error) in
			if let masterBracket = masterBracket {
				//Set temp variable, which will eventually set the parent's master bracket, or show the create bracket view
				self.tmpMasterBracket = masterBracket
            } else {
                super.displayAlert(error: error)
            }
        }
    }
	
	private func displayCreateBracketView() {
		self.createBracketView.isHidden = false
		self.view.bringSubviewToFront(self.createBracketView)
	}
	
	private var noBracket = false
	private var tmpBracket: Bracket? {
		didSet {
			if let bracket = tmpBracket {
				//We have a bracket for this tournament
				if super.masterBracket != nil {
					//We already loaded the master. Setup the UI
					super.bracket = bracket
				}
			} else {
				//We don't have a bracket yet for this tournament
				if super.masterBracket != nil {
					//We already loaded the master. Setup the UI
					displayCreateBracketView()
				} else {
					//We are still waiting for the master... Cache the fact that we don't have a bracket
					noBracket = true
				}
			}
		}
	}
	private var tmpMasterBracket: Bracket? {
		didSet {
			super.masterBracket = tmpMasterBracket
			
			if let myBracket = self.tmpBracket {
				//We already loaded (and cached) my bracket. Setup the UI
				super.bracket = myBracket
			} else if self.noBracket {
				//We already loaded my bracket, but I don't have one. Setup the UI
				self.displayCreateBracketView()
			}
		}
	}
}

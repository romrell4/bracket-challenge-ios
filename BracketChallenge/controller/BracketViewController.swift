//
//  BracketViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/15/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class BracketViewController: UIViewController, MatchViewClickableDelegate {
	
	//MARK: Public properties
	var tournament: Tournament!
	var bracket: Bracket? {
		didSet {
			bracketView?.bracket = bracket
		}
	}
	var masterBracket: Bracket? {
		didSet {
			bracketView?.masterBracket = masterBracket
		}
	}
	var spinner: UIActivityIndicatorView! { return bracketView.spinner }
	
	//MARK: Private Outlets
	private var bracketView: BracketView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		bracketView = BracketView.initAsSubview(in: view, clickDelegate: self, tournament: tournament)
		
		//If either of the brackets were set before the view was loaded, set them now
		if let bracket = bracket {
			bracketView.bracket = bracket
		}
		if let masterBracket = masterBracket {
			bracketView.masterBracket = masterBracket
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		if bracketView.changesMade {
			BCClient.updateBracket(bracket: bracketView.bracket, callback: { (bracket, error) in
				if bracket != nil {
					//This will delete the cached bracket
					self.bracketView.changesMade = false
				}
			})
		}
	}
	
	//MARK: MatchViewClickableDelegate
	
	func areCellsClickable() -> Bool {
		//Override if you want to stop users from selecting the rows
		return true
	}
}

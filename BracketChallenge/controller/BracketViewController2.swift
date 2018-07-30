//
//  BracketViewController2.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/15/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class BracketViewController2: UIViewController, MatchViewClickableDelegate {
	
	//MARK: Public properties
	var tournament: Tournament!
	var bracket: Bracket! {
		didSet {
			//Sometimes, this will be set before viewDidLoad is called. If that is the case, wait for the viewDidLoad to load the UI
			if isViewLoaded {
				bracketView = BracketView.initAsSubview(in: view, clickDelegate: self, tournament: tournament, bracket: bracket)
			}
		}
	}
	
	//MARK: Private Outlets
	private var bracketView: BracketView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//If the bracket was set before this was called, load the bracket UI now
		if let bracket = bracket {
			bracketView = BracketView.initAsSubview(in: view, clickDelegate: self, tournament: tournament, bracket: bracket)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		//When this tab is selectd, reset the title to the bracket name
		tabBarController?.title = bracket?.name
	}
	
	//MARK: Listeners
	
	@objc func updateBracket() {
		if let bracket = bracket {
			bracketView.spinner.startAnimating()
			BCClient.updateBracket(bracket: bracket, callback: { (bracket, error) in
				self.bracketView.spinner.stopAnimating()
				if let bracket = bracket {
					self.bracket = bracket
					super.displayAlert(title: "Success", message: "Bracket successfully updated", alertHandler: nil)
				} else {
					super.displayAlert(error: error)
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

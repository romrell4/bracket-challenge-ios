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
			//If we aren't in a tab controller, the top line will set the title. Otherwise, the bottom one will.
			title = bracket?.name
			tabBarController?.title = bracket?.name
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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		//When this tab is selected, reset the title to the bracket name
		tabBarController?.title = bracket?.name
	}
	
	//MARK: MatchViewClickableDelegate
	
	func areCellsClickable() -> Bool {
		//Override if you want to stop users from selecting the rows
		return true
	}
	
	//MARK: Listeners
	
	@objc func updateBracket() {
		if let bracket = bracket {
			spinner.startAnimating()
			BCClient.updateBracket(bracket: bracket, callback: { (bracket, error) in
				self.spinner.stopAnimating()
				if let bracket = bracket {
					self.bracket = bracket
					super.displayAlert(title: "Success", message: "Bracket successfully updated", alertHandler: nil)
				} else {
					super.displayAlert(error: error)
				}
			})
		}
	}
}

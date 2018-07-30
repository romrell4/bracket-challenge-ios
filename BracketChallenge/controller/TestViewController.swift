//
//  TestViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/15/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, UIScrollViewDelegate, RoundViewDelegate {
	
	private struct UI {
		static let roundWidth: CGFloat = UIScreen.main.bounds.width * 0.8
		static let minimumPanAmount = roundWidth / 4
		static let panDuration = 0.5
	}
	
	//MARK: Public Outlets
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	
	//MARK: Public properties
	var tournament: Tournament!
	var bracket: Bracket! {
		didSet {
			//Sometimes, this will be set before viewDidLoad is called. If that is the case, wait for the viewDidLoad to load the UI
			if isViewLoaded {
				loadUI()
			}
		}
	}
	
	//MARK: Private Outlets
	@IBOutlet private weak var pageControl: UIPageControl!
	@IBOutlet private weak var scoreLabel: UILabel!
	@IBOutlet private weak var stackView: UIStackView!
	@IBOutlet private weak var stackViewWidthConstraint: NSLayoutConstraint!
	
	//MARK: Private properties
	private var panOriginX: CGFloat = 0 //TODO: Can you do this natively?
	private var roundViews = [RoundView]()
	private var currentPage = 0 {
		didSet {
			roundViews.enumerated().forEach { (index, roundView) in
				roundView.zoomLevel = Int(pow(2.0, Double(currentPage == 0 ? index : index - currentPage + 1)))
			}
			pageControl.currentPage = currentPage
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//If the bracket was set before this was called, load the bracket UI now
		if bracket != nil {
			loadUI()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		//When this tab is selectd, reset the title to the bracket name
		tabBarController?.title = bracket?.name
	}
	
	//MARK: UIScrollViewDelegate
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		//Keep all visible round views in sync
		roundViews.filter { $0 != scrollView }.forEach {
			$0.contentOffset = scrollView.contentOffset
		}
	}
	
	//MARK: RoundViewDelegate
	
	func areCellsClickable() -> Bool {
		//Override if you want to stop users from selecting the rows
		return true
	}
	
	func player(_ player: Player?, selectedIn roundView: RoundView, and matchView: MatchView) {
		guard let round = roundViews.index(of: roundView), let position = roundView.index(of: matchView) else { return }
		
		//Set the winner
		bracket?.rounds?[round][position].winner = player
		
		//Reload the UI for this match
		roundView.reloadItems(at: position)
		
		//Update the next round
		let nextRound = round + 1
		let newPosition = position / 2 //Integer division will automatically do a "floor"
		if nextRound < roundViews.count {
			let match = bracket?.rounds?[nextRound][newPosition]
			if position % 2 == 0 {
				match?.player1 = player
			} else {
				match?.player2 = player
			}
			
			//Reload the UI for the next match
			roundViews[nextRound].reloadItems(at: newPosition)
		}
	}
	
	//MARK: Listeners
	
	@IBAction func panGestureHandler(_ recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .began:
			panOriginX = recognizer.view?.frame.origin.x ?? 0
		case .changed:
			let translation = recognizer.translation(in: stackView)
			recognizer.view?.frame.origin.x = panOriginX + translation.x
		case .ended:
			//Check the distance moved to determine if we should switch pages
			let translation = recognizer.translation(in: self.stackView).x
			if translation <= -UI.minimumPanAmount && self.currentPage < self.roundViews.count - 1 {
				//We're moving left (and there is another page to our right)
				self.currentPage += 1
			} else if translation >= UI.minimumPanAmount && self.currentPage > 0 {
				//We're moving right (and there is another page to our left)
				self.currentPage -= 1
			}
			
			//Animate the rest of the paging
			UIView.animate(withDuration: UI.panDuration) {
				recognizer.view?.frame.origin.x = 0 - (UI.roundWidth * CGFloat(self.currentPage))
			}
		default: break
		}
	}
	
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
	
	//MARK: Private functions
	
	private func loadUI() {
		navigationItem.title = bracket?.name
		tabBarController?.navigationItem.title = bracket?.name
		scoreLabel.text = "Score: \(bracket?.score ?? 0)"
		
		//Only allow the UI to be loaded once
		if roundViews.count == 0 {
			bracket.rounds?.forEach {
				let roundView = RoundView.fromNib()
				roundView.translatesAutoresizingMaskIntoConstraints = false
				roundView.roundDelegate = self
				roundView.delegate = self
				roundView.matches = $0
				roundViews.append(roundView)
				stackView.addArrangedSubview(roundView)
				
				NSLayoutConstraint.activate([
					roundView.widthAnchor.constraint(equalToConstant: UI.roundWidth)
				])
			}
			
			//Allow the stack view enough space to see everything
			stackViewWidthConstraint.constant = UI.roundWidth * CGFloat(bracket.rounds?.count ?? 0)
			
			//This will make sure all of the spacing is correct
			pageControl.numberOfPages = roundViews.count
			currentPage = 0
		}
	}
}

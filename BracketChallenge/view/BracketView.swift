//
//  BracketView.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/29/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class BracketView: UIView, UIScrollViewDelegate, RoundViewDelegate {
	private struct UI {
		static let roundWidth: CGFloat = UIScreen.main.bounds.width * 0.8
		static let minimumPanAmount = roundWidth / 4
		static let panDuration = 0.3
	}
	
	//MARK: Public outlets
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	
	//MARK: Public properties
	var bracket: Bracket! {
		didSet {
			loadUI()
		}
	}
	var masterBracket: Bracket? {
		didSet {
			loadUI()
		}
	}
	
	//MARK: Private outlets
	@IBOutlet private weak var topView: UIView!
	@IBOutlet private weak var pageControl: UIPageControl!
	@IBOutlet private weak var scoreLabel: UILabel!
	@IBOutlet private weak var stackView: UIStackView!
	@IBOutlet private weak var stackViewWidthConstraint: NSLayoutConstraint!
	
	//MARK: Private properties
	private var tournament: Tournament!
	private var clickDelegate: MatchViewClickableDelegate!
	private var roundViews = [RoundView]()
	private var currentPage = 0 {
		didSet {
			roundViews.enumerated().forEach { (index, roundView) in
				roundView.zoomLevel = Int(pow(2.0, Double(currentPage == 0 ? index : index - currentPage + 1)))
			}
			pageControl.currentPage = currentPage
		}
	}
	
	static func initAsSubview(in superview: UIView, clickDelegate: MatchViewClickableDelegate, tournament: Tournament) -> BracketView {
		let bracketView = UINib(nibName: "BracketView", bundle: nil).instantiate(withOwner: nil).first as! BracketView
		bracketView.translatesAutoresizingMaskIntoConstraints = false
		superview.addSubview(bracketView)
		NSLayoutConstraint.activate([
			bracketView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
			bracketView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
			bracketView.topAnchor.constraint(equalTo: superview.topAnchor),
			bracketView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
		])
		//Set this first so that the variable is saved when the bracket loads all it's matches (didSet)
		bracketView.clickDelegate = clickDelegate
		bracketView.tournament = tournament
		return bracketView
	}
	
	//MARK: UIScrollViewDelegate
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		//Keep all visible round views in sync
		roundViews.filter { $0 != scrollView }.forEach {
			$0.contentOffset = scrollView.contentOffset
		}
	}
	
	//MARK: RoundViewDelegate
	
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
			//Save the original position as the tag (so that you can base the translation off of it)
			recognizer.view?.tag = Int(recognizer.view?.frame.origin.x ?? 0)
		case .changed:
			let translation = recognizer.translation(in: stackView)
			recognizer.view?.frame.origin.x = CGFloat(recognizer.view?.tag ?? 0) + translation.x
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
	
	//MARK: Private functions
	
	private func loadUI() {
		//Only load the UI if the user's bracket is loaded already (if the master gets loaded, wait until the user's bracket loads
		if let bracket = bracket {
			spinner.stopAnimating()
			topView.isHidden = false
			
			scoreLabel.text = "Score: \(bracket.score)"
			
			//Only allow the UI to be loaded once
			roundViews.forEach {
				$0.removeFromSuperview()
			}
			roundViews.removeAll(keepingCapacity: true)
			
			for i in 0..<(bracket.rounds?.count ?? 0) {
				let roundView = RoundView.initWith(scrollDelegate: self, roundDelegate: self, clickDelegate: clickDelegate, matches: bracket.rounds?[i] ?? [], masterMatches: masterBracket?.rounds?[i])
				roundView.translatesAutoresizingMaskIntoConstraints = false
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

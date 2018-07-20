//
//  TestViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/15/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, UIScrollViewDelegate, MatchViewDelegate {
	
	private struct UI {
		static let roundWidth: CGFloat = UIScreen.main.bounds.width * 0.8
		static let minimumPanAmount = roundWidth / 4
		static let animateDuration = 0.5
	}
	
	//MARK: Outlets
	@IBOutlet private weak var pageControl: UIPageControl!
	@IBOutlet private weak var scoreLabel: UILabel!
	@IBOutlet private weak var stackView: UIStackView!
	@IBOutlet private weak var stackViewWidthConstraint: NSLayoutConstraint!
	
	//MARK: Public properties
	var bracket: Bracket! {
		didSet {
			//Sometimes, this will be set before viewDidLoad is called. If that is the case, wait for the viewDidLoad to load the UI
			if isViewLoaded {
				loadUI()
			}
		}
	}
	
	//MARK: Private properties
	private var panOriginX: CGFloat = 0
	private var roundViews = [RoundView]()
	private var currentPage = 0 {
		didSet {
			if currentPage == 0 {
				roundViews.enumerated().forEach { (index, roundView) in
					roundView.zoomLevel = Int(pow(2.0, Double(index)))
				}
			} else {
				roundViews.enumerated().forEach { (index, roundView) in
					roundView.zoomLevel = Int(pow(2.0, Double(index - currentPage + 1)))
				}
			}
			pageControl.currentPage = currentPage
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		bracket = Bracket(bracketId: 1, userId: 1, tournamentId: 1, name: "Test", score: 0, rounds: [
			[
				MatchHelper(round: 1, position: 1, player1Id: 1, player1Name: "Player 1", player2Id: 2, player2Name: "Player 2", winnerId: 1),
				MatchHelper(round: 1, position: 2, player1Id: 3, player1Name: "Player 3", player2Id: 4, player2Name: "Player 4", winnerId: 3),
				MatchHelper(round: 1, position: 3, player1Id: 5, player1Name: "Player 5", player2Id: 6, player2Name: "Player 6", winnerId: 5),
				MatchHelper(round: 1, position: 4, player1Id: 7, player1Name: "Player 7", player2Id: 8, player2Name: "Player 8", winnerId: 7),
				MatchHelper(round: 1, position: 5, player1Id: 9, player1Name: "Player 9", player2Id: 10, player2Name: "Player 10", winnerId: 9),
				MatchHelper(round: 1, position: 6, player1Id: 11, player1Name: "Player 11", player2Id: 12, player2Name: "Player 12", winnerId: 11),
				MatchHelper(round: 1, position: 7, player1Id: 13, player1Name: "Player 13", player2Id: 14, player2Name: "Player 14", winnerId: 13),
				MatchHelper(round: 1, position: 8, player1Id: 15, player1Name: "Player 15", player2Id: 16, player2Name: "Player 16", winnerId: 15),
				MatchHelper(round: 1, position: 9, player1Id: 17, player1Name: "Player 17", player2Id: 18, player2Name: "Player 18", winnerId: 17),
				MatchHelper(round: 1, position: 10, player1Id: 19, player1Name: "Player 19", player2Id: 20, player2Name: "Player 20", winnerId: 19),
				MatchHelper(round: 1, position: 11, player1Id: 21, player1Name: "Player 21", player2Id: 22, player2Name: "Player 22", winnerId: 21),
				MatchHelper(round: 1, position: 12, player1Id: 23, player1Name: "Player 23", player2Id: 24, player2Name: "Player 24", winnerId: 23),
				MatchHelper(round: 1, position: 13, player1Id: 25, player1Name: "Player 25", player2Id: 26, player2Name: "Player 26", winnerId: 25),
				MatchHelper(round: 1, position: 14, player1Id: 27, player1Name: "Player 27", player2Id: 28, player2Name: "Player 28", winnerId: 27),
				MatchHelper(round: 1, position: 15, player1Id: 29, player1Name: "Player 29", player2Id: 30, player2Name: "Player 30", winnerId: 29),
				MatchHelper(round: 1, position: 16, player1Id: 31, player1Name: "Player 31", player2Id: 32, player2Name: "Player 32", winnerId: 31),
				MatchHelper(round: 1, position: 17, player1Id: 33, player1Name: "Player 33", player2Id: 34, player2Name: "Player 34", winnerId: 33),
				MatchHelper(round: 1, position: 18, player1Id: 35, player1Name: "Player 35", player2Id: 36, player2Name: "Player 36", winnerId: 35),
				MatchHelper(round: 1, position: 19, player1Id: 37, player1Name: "Player 37", player2Id: 38, player2Name: "Player 38", winnerId: 37),
				MatchHelper(round: 1, position: 20, player1Id: 39, player1Name: "Player 39", player2Id: 40, player2Name: "Player 40", winnerId: 39),
				MatchHelper(round: 1, position: 21, player1Id: 41, player1Name: "Player 41", player2Id: 42, player2Name: "Player 42", winnerId: 41),
				MatchHelper(round: 1, position: 22, player1Id: 43, player1Name: "Player 43", player2Id: 44, player2Name: "Player 44", winnerId: 43),
				MatchHelper(round: 1, position: 23, player1Id: 45, player1Name: "Player 45", player2Id: 46, player2Name: "Player 46", winnerId: 45),
				MatchHelper(round: 1, position: 24, player1Id: 47, player1Name: "Player 47", player2Id: 48, player2Name: "Player 48", winnerId: 47),
				MatchHelper(round: 1, position: 25, player1Id: 49, player1Name: "Player 49", player2Id: 50, player2Name: "Player 50", winnerId: 49),
				MatchHelper(round: 1, position: 26, player1Id: 51, player1Name: "Player 51", player2Id: 52, player2Name: "Player 52", winnerId: 51),
				MatchHelper(round: 1, position: 27, player1Id: 53, player1Name: "Player 53", player2Id: 54, player2Name: "Player 54", winnerId: 53),
				MatchHelper(round: 1, position: 28, player1Id: 55, player1Name: "Player 55", player2Id: 56, player2Name: "Player 56", winnerId: 55),
				MatchHelper(round: 1, position: 29, player1Id: 57, player1Name: "Player 57", player2Id: 58, player2Name: "Player 58", winnerId: 57),
				MatchHelper(round: 1, position: 30, player1Id: 59, player1Name: "Player 59", player2Id: 60, player2Name: "Player 60", winnerId: 59),
				MatchHelper(round: 1, position: 31, player1Id: 61, player1Name: "Player 61", player2Id: 62, player2Name: "Player 62", winnerId: 61),
				MatchHelper(round: 1, position: 32, player1Id: 63, player1Name: "Player 63", player2Id: 64, player2Name: "Player 64", winnerId: 63)
			],
			[
				MatchHelper(round: 2, position: 1, player1Id: 1, player1Name: "Player 1", player2Id: 3, player2Name: "Player 3", winnerId: 1),
				MatchHelper(round: 2, position: 2, player1Id: 5, player1Name: "Player 5", player2Id: 7, player2Name: "Player 7", winnerId: 5),
				MatchHelper(round: 2, position: 3, player1Id: 9, player1Name: "Player 9", player2Id: 11, player2Name: "Player 11", winnerId: 9),
				MatchHelper(round: 2, position: 4, player1Id: 13, player1Name: "Player 13", player2Id: 15, player2Name: "Player 15", winnerId: 13),
				MatchHelper(round: 2, position: 5, player1Id: 17, player1Name: "Player 17", player2Id: 19, player2Name: "Player 19", winnerId: 17),
				MatchHelper(round: 2, position: 6, player1Id: 21, player1Name: "Player 21", player2Id: 23, player2Name: "Player 23", winnerId: 21),
				MatchHelper(round: 2, position: 7, player1Id: 25, player1Name: "Player 25", player2Id: 27, player2Name: "Player 27", winnerId: 25),
				MatchHelper(round: 2, position: 8, player1Id: 29, player1Name: "Player 29", player2Id: 31, player2Name: "Player 31", winnerId: 29),
				MatchHelper(round: 2, position: 9, player1Id: 33, player1Name: "Player 33", player2Id: 35, player2Name: "Player 35", winnerId: 33),
				MatchHelper(round: 2, position: 10, player1Id: 37, player1Name: "Player 37", player2Id: 39, player2Name: "Player 39", winnerId: 37),
				MatchHelper(round: 2, position: 11, player1Id: 41, player1Name: "Player 41", player2Id: 43, player2Name: "Player 43", winnerId: 41),
				MatchHelper(round: 2, position: 12, player1Id: 45, player1Name: "Player 45", player2Id: 47, player2Name: "Player 47", winnerId: 45),
				MatchHelper(round: 2, position: 13, player1Id: 49, player1Name: "Player 49", player2Id: 51, player2Name: "Player 51", winnerId: 49),
				MatchHelper(round: 2, position: 14, player1Id: 53, player1Name: "Player 53", player2Id: 55, player2Name: "Player 55", winnerId: 53),
				MatchHelper(round: 2, position: 15, player1Id: 57, player1Name: "Player 57", player2Id: 59, player2Name: "Player 59", winnerId: 57),
				MatchHelper(round: 2, position: 16, player1Id: 61, player1Name: "Player 61", player2Id: 63, player2Name: "Player 63", winnerId: 61)
			],
			[
				MatchHelper(round: 3, position: 1, player1Id: 1, player1Name: "Player 1", player2Id: 5, player2Name: "Player 5", winnerId: 1),
				MatchHelper(round: 3, position: 2, player1Id: 9, player1Name: "Player 9", player2Id: 13, player2Name: "Player 13", winnerId: 9),
				MatchHelper(round: 3, position: 3, player1Id: 17, player1Name: "Player 17", player2Id: 21, player2Name: "Player 21", winnerId: 17),
				MatchHelper(round: 3, position: 4, player1Id: 25, player1Name: "Player 25", player2Id: 29, player2Name: "Player 29", winnerId: 25),
				MatchHelper(round: 3, position: 5, player1Id: 33, player1Name: "Player 33", player2Id: 37, player2Name: "Player 37", winnerId: 33),
				MatchHelper(round: 3, position: 6, player1Id: 41, player1Name: "Player 41", player2Id: 45, player2Name: "Player 45", winnerId: 41),
				MatchHelper(round: 3, position: 7, player1Id: 49, player1Name: "Player 49", player2Id: 53, player2Name: "Player 53", winnerId: 49),
				MatchHelper(round: 3, position: 8, player1Id: 57, player1Name: "Player 57", player2Id: 61, player2Name: "Player 61", winnerId: 57)
			],
			[
				MatchHelper(round: 4, position: 1, player1Id: 1, player1Name: "Player 1", player2Id: 9, player2Name: "Player 9", winnerId: 1),
				MatchHelper(round: 4, position: 2, player1Id: 17, player1Name: "Player 17", player2Id: 25, player2Name: "Player 25", winnerId: 17),
				MatchHelper(round: 4, position: 3, player1Id: 33, player1Name: "Player 33", player2Id: 41, player2Name: "Player 41", winnerId: 33),
				MatchHelper(round: 4, position: 4, player1Id: 49, player1Name: "Player 49", player2Id: 57, player2Name: "Player 57", winnerId: 49)
			],
			[
				MatchHelper(round: 5, position: 1, player1Id: 1, player1Name: "Player 1", player2Id: 17, player2Name: "Player 17", winnerId: 1),
				MatchHelper(round: 5, position: 2, player1Id: 33, player1Name: "Player 33", player2Id: 49, player2Name: "Player 49", winnerId: 33)
			],
			[
				MatchHelper(round: 6, position: 1, player1Id: 1, player1Name: "Player 1", player2Id: 33, player2Name: "Player 33", winnerId: 1)
			]
		])
		if bracket != nil {
			loadUI()
		}
	}
	
	//MARK: UIScrollViewDelegate
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		//Keep all visible round views in sync
		roundViews.filter { $0 != scrollView }.forEach {
			$0.contentOffset = scrollView.contentOffset
		}
	}
	
	//MARK: MatchViewDelegate
	
	func player(_ player: Player?, selectedInView view: MatchView) {
		print("Selected \(player?.name ?? "nobody")")
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
			//Animate the cells growing and/or shrinking
			UIView.animate(withDuration: UI.animateDuration) {
				//Check the distance moved to determine if we should switch pages
				let translation = recognizer.translation(in: self.stackView).x
				if translation <= -UI.minimumPanAmount && self.currentPage < self.roundViews.count - 1 {
					//We're moving left (and there is another page to our right)
					self.currentPage += 1
				} else if translation >= UI.minimumPanAmount && self.currentPage > 0 {
					//We're moving right (and there is another page to our left)
					self.currentPage -= 1
				}
				recognizer.view?.frame.origin.x = 0 - (UI.roundWidth * CGFloat(self.currentPage))
			}
		default: break
		}
	}
	
	//MARK: Private functions
	
	private func loadUI() {
		//Only allow the UI to be loaded once
		if roundViews.count == 0 {
			bracket.rounds?.forEach {
				let roundView = RoundView.fromNib()
				roundView.translatesAutoresizingMaskIntoConstraints = false
				roundView.matchDelegate = self
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

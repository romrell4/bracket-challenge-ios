//
//  TestViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/15/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
	private let bracket = Bracket(bracketId: 1, userId: 1, tournamentId: 1, name: "Test", score: 0, rounds: [
		[
			MatchHelper(matchId: 1, bracketId: 1, round: 1, position: 1, player1Id: 1, player1Name: "Player 1", player2Id: 2, player2Name: "Player 2"),
			MatchHelper(matchId: 2, bracketId: 1, round: 1, position: 2, player1Id: 3, player1Name: "Player 3", player2Id: 4, player2Name: "Player 4"),
			MatchHelper(matchId: 3, bracketId: 1, round: 1, position: 3, player1Id: 5, player1Name: "Player 5", player2Id: 6, player2Name: "Player 6"),
			MatchHelper(matchId: 4, bracketId: 1, round: 1, position: 4, player1Id: 7, player1Name: "Player 7", player2Id: 8, player2Name: "Player 8"),
			MatchHelper(matchId: 5, bracketId: 1, round: 1, position: 5, player1Id: 9, player1Name: "Player 9", player2Id: 10, player2Name: "Player 10"),
			MatchHelper(matchId: 6, bracketId: 1, round: 1, position: 6, player1Id: 11, player1Name: "Player 11", player2Id: 12, player2Name: "Player 12"),
			MatchHelper(matchId: 7, bracketId: 1, round: 1, position: 7, player1Id: 13, player1Name: "Player 13", player2Id: 14, player2Name: "Player 14"),
			MatchHelper(matchId: 8, bracketId: 1, round: 1, position: 8, player1Id: 15, player1Name: "Player 15", player2Id: 16, player2Name: "Player 16"),
			MatchHelper(matchId: 9, bracketId: 1, round: 1, position: 9, player1Id: 17, player1Name: "Player 17", player2Id: 18, player2Name: "Player 18")
		]
	])
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		bracket.rounds?.forEach {
			view.addSubview(RoundView(matches: $0, superview: view))
		}
	}
}

class RoundView: UIScrollView {
	//MARK: Private properties
	private let stackView = UIStackView()
	private var topBottomConstraints: [NSLayoutConstraint]!
	private var zoomLevel: CGFloat = 1 {
		didSet {
			let spacing = (zoomLevel - 1) * TABLE_CELL_HEIGHT
			topBottomConstraints.forEach { $0.constant = spacing }

			UIView.animate(withDuration: 0.5) {
				self.stackView.spacing = spacing
				self.setNeedsLayout()
			}
		}
	}
	
	init(matches: [MatchHelper], superview: UIView) {
		super.init(frame: CGRect())
		
		translatesAutoresizingMaskIntoConstraints = false
		backgroundColor = .lightGray
		superview.addSubview(self)
		
		NSLayoutConstraint.activate([
			leadingAnchor.constraint(equalTo: superview.leadingAnchor),
			trailingAnchor.constraint(equalTo: superview.trailingAnchor),
			topAnchor.constraint(equalTo: superview.topAnchor),
			bottomAnchor.constraint(equalTo: superview.bottomAnchor)
		])
		
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 20
		addSubview(stackView)
		
		topBottomConstraints = [
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
		]

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			topBottomConstraints[0],
			topBottomConstraints[1],
			stackView.widthAnchor.constraint(equalTo: widthAnchor)
		])

		matches.forEach { match in
			if let matchView = UINib(nibName: "MatchCollectionViewCell", bundle: nil).instantiate(withOwner: self, options: nil).first as? MatchCollectionViewCell {
				matchView.match = match
				stackView.addArrangedSubview(matchView)
				
				NSLayoutConstraint.activate([
					matchView.heightAnchor.constraint(equalToConstant: TABLE_CELL_HEIGHT * 2)
				])
			}
		}
		
		//Add gesture recognizer for testing
		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(sender:))))
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	//MARK: Listeners
	
	@objc func tap(sender: UIPanGestureRecognizer) {
		if sender.state == .ended {
			if sender.location(in: self).x > self.frame.width / 2 {
				zoomLevel *= 2
			} else {
				zoomLevel /= 2
			}
		}
	}
}


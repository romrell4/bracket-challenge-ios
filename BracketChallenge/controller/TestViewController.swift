//
//  TestViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/15/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, MatchViewDelegate {
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
			MatchHelper(matchId: 9, bracketId: 1, round: 1, position: 9, player1Id: 17, player1Name: "Player 17", player2Id: 18, player2Name: "Player 18"),
			MatchHelper(matchId: 10, bracketId: 1, round: 1, position: 10, player1Id: 19, player1Name: "Player 19", player2Id: 20, player2Name: "Player 20"),
			MatchHelper(matchId: 11, bracketId: 1, round: 1, position: 11, player1Id: 21, player1Name: "Player 21", player2Id: 22, player2Name: "Player 22"),
			MatchHelper(matchId: 12, bracketId: 1, round: 1, position: 12, player1Id: 23, player1Name: "Player 23", player2Id: 24, player2Name: "Player 24"),
			MatchHelper(matchId: 13, bracketId: 1, round: 1, position: 13, player1Id: 25, player1Name: "Player 25", player2Id: 26, player2Name: "Player 26"),
			MatchHelper(matchId: 14, bracketId: 1, round: 1, position: 14, player1Id: 27, player1Name: "Player 27", player2Id: 28, player2Name: "Player 28"),
			MatchHelper(matchId: 15, bracketId: 1, round: 1, position: 15, player1Id: 29, player1Name: "Player 29", player2Id: 30, player2Name: "Player 30"),
			MatchHelper(matchId: 16, bracketId: 1, round: 1, position: 16, player1Id: 31, player1Name: "Player 31", player2Id: 32, player2Name: "Player 32")
		]
	])
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		bracket.rounds?.forEach {
			if let roundView = UINib(nibName: "RoundView", bundle: nil).instantiate(withOwner: self, options: nil).first as? RoundView {
				roundView.translatesAutoresizingMaskIntoConstraints = false
				roundView.matchDelegate = self
				roundView.matches = $0
				view.addSubview(roundView)
				
				NSLayoutConstraint.activate([
					roundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
					roundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
					roundView.topAnchor.constraint(equalTo: view.topAnchor),
					roundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
				])
			}
		}
	}
	
	//MARK: MatchViewDelegate
	
	func player(_ player: Player?, selectedInView view: MatchView) {
		print("Selected \(player?.name ?? "nobody")")
	}
}

//
//  RoundView.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/15/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class RoundView: UIScrollView {
	//MARK: Outlets
	@IBOutlet private weak var stackView: UIStackView!
	@IBOutlet private var topBottomConstraints: [NSLayoutConstraint]!
	
	//MARK: Public properties
	var matchDelegate: MatchViewDelegate!
	var matches = [MatchHelper]() {
		didSet {
			matches.forEach { match in
				if let matchView = UINib(nibName: "MatchView", bundle: nil).instantiate(withOwner: self, options: nil).first as? MatchView {
					matchView.delegate = matchDelegate
					matchView.match = match
					stackView.addArrangedSubview(matchView)
					
					NSLayoutConstraint.activate([
						matchView.heightAnchor.constraint(equalToConstant: MATCH_CELL_HEIGHT * 2)
					])
				}
			}
		}
	}
	
	//MARK: Private properties
	private var zoomLevel: CGFloat = 1 {
		didSet {
			let spacing = (zoomLevel - 1) * MATCH_CELL_HEIGHT
			topBottomConstraints.forEach { $0.constant = spacing }
			
			UIView.animate(withDuration: 0.5) {
				//TODO: Also animate scroll contentOffset so that the top stays the same
				self.stackView.spacing = spacing
				self.setNeedsLayout()
			}
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

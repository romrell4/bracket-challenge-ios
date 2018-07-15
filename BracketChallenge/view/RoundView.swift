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
	var matches = [MatchHelper]() {
		didSet {
			matches.forEach { match in
				if let matchView = UINib(nibName: "MatchCollectionViewCell", bundle: nil).instantiate(withOwner: self, options: nil).first as? MatchCollectionViewCell {
					matchView.match = match
					stackView.addArrangedSubview(matchView)
					
					NSLayoutConstraint.activate([
						matchView.heightAnchor.constraint(equalToConstant: TABLE_CELL_HEIGHT * 2)
					])
				}
			}
		}
	}
	
	
	//MARK: Private properties
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
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	//MARK: Listeners
	
	@IBAction func tap(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			if sender.location(in: self).x > self.frame.width / 2 {
				zoomLevel *= 2
			} else {
				zoomLevel /= 2
			}
		}
	}
}

//
//  RoundView.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/15/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

private let MATCH_VIEW_HEIGHT = MATCH_CELL_HEIGHT * 2

class RoundView: UIScrollView {
	private struct UI {
		static let cellAnimationDuration = 0.5
	}
	
	//MARK: Outlets
	@IBOutlet private weak var stackView: UIStackView!
	@IBOutlet private var topBottomConstraints: [NSLayoutConstraint]!
	
	//MARK: Public properties
	var matchDelegate: MatchViewDelegate!
	var matches = [MatchHelper]() {
		didSet {
			matchViews.removeAll(keepingCapacity: true)
			matches.forEach { match in
				if let matchView = UINib(nibName: "MatchView", bundle: nil).instantiate(withOwner: self, options: nil).first as? MatchView {
					matchView.delegate = matchDelegate
					matchView.match = match
					stackView.addArrangedSubview(matchView)
					
					NSLayoutConstraint.activate([
						matchView.heightAnchor.constraint(equalToConstant: MATCH_VIEW_HEIGHT)
					])
					matchViews.append(matchView)
				}
			}
		}
	}

	var zoomLevel: Int = 1 {
		didSet {
			let spacing = CGFloat(zoomLevel - 1) * MATCH_VIEW_HEIGHT
			let currentScrollPercentage = contentSize.height != 0 ? contentOffset.y / contentSize.height: 0
			let newHeight = CGFloat(matches.count) * (MATCH_VIEW_HEIGHT + spacing)
			topBottomConstraints.forEach { $0.constant = spacing / 2 }
			
			UIView.animate(withDuration: UI.cellAnimationDuration) {
				//Make the scroll percentage stay the same after the scroll
				self.contentOffset.y = currentScrollPercentage * newHeight
				self.stackView.spacing = spacing
				self.setNeedsLayout()
			}
		}
	}
	
	//MARK: Private properties
	private var matchViews = [MatchView]()
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	//MARK: Public Functions
	
	static func fromNib() -> RoundView {
		if let roundView = UINib(nibName: "RoundView", bundle: nil).instantiate(withOwner: nil).first as? RoundView {
			return roundView
		}
		fatalError("Unable to create RoundView from nib")
	}
	
	func index(of matchView: MatchView) -> Int? {
		return matchViews.index(of: matchView)
	}
	
	func reloadItems(at index: Int) {
		matchViews[index].match = matches[index]
	}
}

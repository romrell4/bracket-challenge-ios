//
//  RoundView.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/15/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

private let MATCH_VIEW_HEIGHT = MATCH_CELL_HEIGHT * 2

protocol RoundViewDelegate {
	func areCellsClickable() -> Bool
	func player(_ player: Player?, selectedIn roundView: RoundView, and matchView: MatchView)
}

class RoundView: UIScrollView, MatchViewDelegate {
	private struct UI {
		static let cellAnimationDuration = 0.5
	}
	
	//MARK: Outlets
	@IBOutlet private weak var stackView: UIStackView!
	@IBOutlet private var topBottomConstraints: [NSLayoutConstraint]!
	
	//MARK: Public properties
	var roundDelegate: RoundViewDelegate!
	var matches = [MatchHelper]() {
		didSet {
			matchViews.removeAll(keepingCapacity: true)
			matches.forEach { match in
				if let matchView = UINib(nibName: "MatchView", bundle: nil).instantiate(withOwner: self, options: nil).first as? MatchView {
					matchView.delegate = self
					matchView.match = match
					matchView.areCellsClickable = roundDelegate.areCellsClickable()
					stackView.addArrangedSubview(matchView)
					
					NSLayoutConstraint.activate([
						matchView.heightAnchor.constraint(equalToConstant: MATCH_VIEW_HEIGHT)
					])
					matchViews.append(matchView)
				}
			}
		}
	}

	var zoomLevel: Int! {
		didSet {
			let spacing = CGFloat(zoomLevel - 1) * MATCH_VIEW_HEIGHT
			let currentScrollPercentage = contentSize.height != 0 ? contentOffset.y / contentSize.height : 0
			let newHeight = CGFloat(matches.count) * (MATCH_VIEW_HEIGHT + spacing)

			topBottomConstraints.forEach { $0.constant = spacing / 2 }

			if oldValue == nil {
				//If this is the first time, don't animate
				stackView.spacing = spacing
			} else {
				//Remove the delegate so that the scroll views don't try to sync during the animation
				let oldDelegate = delegate
				delegate = nil
				UIView.animate(withDuration: UI.cellAnimationDuration, animations: {
					//Make the scroll percentage stay the same after the scroll
					self.contentOffset.y = currentScrollPercentage * newHeight
					self.stackView.spacing = spacing
					self.setNeedsLayout()
				}) { (_) in
					//Reset the delegate and manually trigger the scroll view syncing
					self.delegate = oldDelegate
					self.delegate?.scrollViewDidScroll?(self)
				}
			}
		}
	}
	
	//MARK: Private properties
	private var matchViews = [MatchView]()
	
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
	
	//MARK: MatchViewDelegate
	
	func player(_ player: Player?, selectedInView view: MatchView) {
		roundDelegate.player(player, selectedIn: self, and: view)
	}
}

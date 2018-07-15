//
//  RoundView.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/15/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class RoundView: UIScrollView {
	//MARK: Public properties
	var matches = [MatchHelper]() {
		didSet {
			translatesAutoresizingMaskIntoConstraints = false
			backgroundColor = .lightGray
			
			stackView.translatesAutoresizingMaskIntoConstraints = false
			stackView.axis = .vertical
			addSubview(stackView)
			
			//Save these so that we can change them with the stack view spacing
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
	}
	
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
	
	init() {
		super.init(frame: CGRect())
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

//
//  TournamentTableViewCell.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/31/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

private let ANIMATION_DURATION = 0.4
private let SELECTED_ALPHA: CGFloat = 0.80
private let UNSELECTED_ALPHA: CGFloat = 0.4

class TournamentTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    func setTournament(_ tournament: Tournament) {
		//TODO: Add tournament dates here
        titleLabel.text = tournament.name
        if let image = tournament.image {
            backgroundImageView.image = image
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        //For some reason, the view reset when selected. This should set them back to what they should be
        lineView.backgroundColor = .white
        overlayView.backgroundColor = .black
        
        //Animate the dimming of the cell when it is selected
        UIView.animate(withDuration: ANIMATION_DURATION) {
            self.overlayView.alpha = selected ? SELECTED_ALPHA : UNSELECTED_ALPHA
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        //Do nothing. Just override it so that they don't highlight it when the user clicks.
    }
}

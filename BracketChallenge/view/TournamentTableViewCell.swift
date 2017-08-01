//
//  TournamentTableViewCell.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/31/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

private let ANIMATION_DURATION = 0.25
private let SELECTED_ALPHA: CGFloat = 0.75
private let UNSELECTED_ALPHA: CGFloat = 0.4

class TournamentTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    func setTournament(_ tournament: Tournament) {
        titleLabel.text = tournament.name
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        lineView.backgroundColor = .white
        overlayView.backgroundColor = .black
        UIView.animate(withDuration: ANIMATION_DURATION) {
            self.overlayView.alpha = selected ? SELECTED_ALPHA : UNSELECTED_ALPHA
        }
    }
}

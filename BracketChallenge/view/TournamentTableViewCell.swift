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
private let DATE_FORMAT = DateFormatter.defaultDateFormat("MM/dd/yy")

class TournamentTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var overlayView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var lineView: UIView!
    @IBOutlet private weak var datesLabel: UILabel!
    
	var tournament: Tournament! {
		didSet {
			titleLabel.text = tournament.name
            
            if let startDate = tournament.startDate, let endDate = tournament.endDate {
                datesLabel.text = "\(DATE_FORMAT.string(from: startDate)) - \(DATE_FORMAT.string(from: endDate))"
            }
			
            //Asynchronously load the image
            if tournament.image != nil {
                self.backgroundImageView.image = self.tournament.image
            } else {
                DispatchQueue.global(qos: .utility).async {
                    if let imageUrl = self.tournament.imageUrl, let url = URL(string: imageUrl), let data = try? Data(contentsOf: url) {
                        self.tournament.image = UIImage(data: data)
                        DispatchQueue.main.async {
                            self.backgroundImageView.image = self.tournament.image
                        }
                    }
                }
            }
		}
	}
	
	@objc func loadImage() {
		DispatchQueue.main.async {
			self.backgroundImageView.image = self.tournament.image
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

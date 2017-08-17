//
//  MatchTableViewCell.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/4/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

protocol MatchTableViewCellDelegate {
    func selected(cell: MatchTableViewCell)
}

class MatchTableViewCell: UITableViewCell {
    //Outlets
    @IBOutlet weak var nameLabel: UILabel!
    
    //Public properties
    var delegate: MatchTableViewCellDelegate?
    
    //Private properties
    var checked: Bool = false {
        didSet {
            if checked {
                accessoryType = .checkmark
                delegate?.selected(cell: self)
            } else {
                accessoryType = .none
            }
        }
    }
    
    //Override these functions so that the default behavior doesn't happen
    override func setSelected(_ selected: Bool, animated: Bool) {}
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {}
}

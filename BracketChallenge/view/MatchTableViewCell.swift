//
//  MatchTableViewCell.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/4/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class MatchTableViewCell: UITableViewCell {
    //Outlets
    @IBOutlet weak var nameLabel: UILabel!
    
    //Override these functions so that the default behavior doesn't happen
    override func setSelected(_ selected: Bool, animated: Bool) {
        accessoryType = selected ? .checkmark : .none
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {}
}

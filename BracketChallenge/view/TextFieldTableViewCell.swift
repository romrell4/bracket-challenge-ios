//
//  TextFieldTableViewCell.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 2/13/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.borderStyle = .none
        }
    }
}

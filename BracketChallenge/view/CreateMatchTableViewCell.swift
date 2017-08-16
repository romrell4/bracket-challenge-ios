//
//  CreateMatchTableViewCell.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/14/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class CreateMatchTableViewCell: UITableViewCell, UITextFieldDelegate {
    //Outlets
    @IBOutlet private weak var playerNameField: UITextField!
    @IBOutlet private weak var seedField: UITextField!
    
    //Public properties
    var players = [Player]()
    
    override func awakeFromNib() {
        playerNameField.delegate = self
    }
    
    //MARK: UITextFieldDelegate callbacks
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let player = players.first(where: { $0.name?.lowercased() == textField.text?.lowercased() }) {
            //TODO: Save this somehow
            textField.text = player.name
            textField.textColor = .black
        } else {
            //TODO: Notify the user of the issue
            textField.textColor = .red
        }
    }
}

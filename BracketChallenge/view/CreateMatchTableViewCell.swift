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
    var player: Player?
    
    override func awakeFromNib() {
        playerNameField.delegate = self
    }
    
    //MARK: UITextFieldDelegate callbacks
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            player = nil
            return
        }
        
        if let player = players.first(where: { $0.name?.lowercased() == textField.text?.lowercased() }) {
            self.player = player
            textField.text = player.name
            textField.textColor = .black
        } else {
            self.player = Player(name: text)
            textField.textColor = .red
        }
    }
}

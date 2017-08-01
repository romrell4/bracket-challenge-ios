//
//  Player.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/31/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class Player {
    var playerId: Int?
    var name: String?
    
    init(dict: [String: Any]) {
        playerId = dict["player_id"] as? Int
        name = dict["name"] as? String
    }
}

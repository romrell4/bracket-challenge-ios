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
    
    init(dict: [String: Any]) throws {
        guard let playerId = dict["player_id"] as? Int,
            let name = dict["name"] as? String else {
                throw InvalidModelError.player
        }
        
        self.playerId = playerId
        self.name = name
    }
    
    init(id: Int, name: String) {
        self.playerId = id
        self.name = name
    }
}

//
//  Player.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/31/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class Player: Equatable {
    var playerId: Int?
    var name: String?
    var seed: Int?
    
    init(dict: [String: Any]) throws {
        guard let playerId = dict["player_id"] as? Int,
            let name = dict["name"] as? String else {
                throw InvalidModelError.player
        }
        
        self.playerId = playerId
        self.name = name
    }
    
    init(id: Int? = nil, name: String, seed: Int? = nil) {
        self.playerId = id
        self.name = name
        self.seed = seed
    }
	
	static func == (lhs: Player, rhs: Player) -> Bool {
		return lhs.playerId == rhs.playerId && lhs.name == rhs.name && lhs.seed == rhs.seed
	}
}

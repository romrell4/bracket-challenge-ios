//
//  MatchHelper.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/1/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class MatchHelper: Match {
    var player1: Player?
    var player2: Player?
    var winner: Player?
    var player1Full: String? {
        let name = player1?.name
        if let seed = seed1 {
            return "\(name ?? "") (\(seed))"
        } else {
            return name
        }
    }
    var player2Full: String? {
        let name = player2?.name
        if let seed = seed2 {
            return "\(name ?? "") (\(seed))"
        } else {
            return name
        }
    }
    
    override init(dict: [String : Any]) throws {
        try super.init(dict: dict)
        if let id = player1Id, let name = dict["player1_name"] as? String {
            player1 = Player(id: id, name: name)
        }
        if let id = player2Id, let name = dict["player2_name"] as? String {
            player2 = Player(id: id, name: name)
        }
        if let id = winnerId, let name = dict["winner_name"] as? String {
            winner = Player(id: id, name: name)
        }
    }
}

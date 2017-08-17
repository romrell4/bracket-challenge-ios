//
//  MatchHelper.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/1/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class MatchHelper: Match {
    var player1: Player? {
        didSet {
            super.player1Id = player1?.playerId
            super.seed1 = player1?.seed
        }
    }
    var player2: Player? {
        didSet {
            super.player2Id = player2?.playerId
            super.seed2 = player2?.seed
        }
    }
    var winner: Player? {
        didSet {
            super.winnerId = winner?.playerId
        }
    }
    
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
            player1 = Player(id: id, name: name, seed: super.seed1)
        }
        if let id = player2Id, let name = dict["player2_name"] as? String {
            player2 = Player(id: id, name: name, seed: super.seed2)
        }
        if let id = winnerId, let name = dict["winner_name"] as? String {
            winner = Player(id: id, name: name)
        }
    }
}

//
//  Match.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/1/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class Match {
    var matchId: Int?
    var bracketId: Int?
    var round: Int?
    var position: Int?
    var player1Id: Int?
    var player2Id: Int?
    var seed1: Int?
    var seed2: Int?
    var winnerId: Int?
    
    init(dict: [String: Any]) throws {
        guard let matchId = dict["match_id"] as? Int,
            let bracketId = dict["bracket_id"] as? Int,
            let round = dict["round"] as? Int,
            let position = dict["position"] as? Int else {
                throw InvalidModelError.match
        }
        
        self.matchId = matchId
        self.bracketId = bracketId
        self.round = round
        self.position = position
        self.player1Id = dict["player1_id"] as? Int
        self.player2Id = dict["player2_id"] as? Int
        self.seed1 = dict["seed1"] as? Int
        self.seed2 = dict["seed2"] as? Int
        self.winnerId = dict["winner_id"] as? Int
    }
}

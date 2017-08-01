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
    
    init(dict: [String: Any]) {
        matchId = dict["match_id"] as? Int
        bracketId = dict["bracket_id"] as? Int
        round = dict["round"] as? Int
        position = dict["position"] as? Int
        player1Id = dict["player1_id"] as? Int
        player2Id = dict["player2_id"] as? Int
        seed1 = dict["seed1"] as? Int
        seed2 = dict["seed2"] as? Int
        winnerId = dict["winner_id"] as? Int
    }
}

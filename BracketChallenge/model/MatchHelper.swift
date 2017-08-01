//
//  MatchHelper.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/1/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class MatchHelper: Match {
    var player1Name: String?
    var player2Name: String?
    var winnerName: String?
    
    override init(dict: [String : Any]) {
        super.init(dict: dict)
        player1Name = dict["player1_name"] as? String
        player2Name = dict["player2_name"] as? String
        winnerName = dict["winner_name"] as? String
    }
}

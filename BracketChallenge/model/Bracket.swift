//
//  Bracket.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/1/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

class Bracket {
    var bracketId: Int?
    var userId: Int?
    var tournamentId: Int?
    var name: String?
    var matches: [MatchHelper]?
    
    init(dict: [String: Any]) {
        bracketId = dict["bracket_id"] as? Int
        userId = dict["user_id"] as? Int
        tournamentId = dict["tournament_id"] as? Int
        name = dict["name"] as? String
        if let matchDicts = dict["matches"] as? [[String: Any]] {
            matches = matchDicts.map({ MatchHelper(dict: $0) })
        }
    }
}

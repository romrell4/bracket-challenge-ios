//
//  Bracket.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/1/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

class Bracket {
    var bracketId: Int
    var userId: Int?
    var tournamentId: Int
    var name: String
    var rounds: [[MatchHelper]]?
    
    init(dict: [String: Any]) throws {
        guard let bracketId = dict["bracket_id"] as? Int, let tournamentId = dict["tournament_id"] as? Int, let name = dict["name"] as? String else {
            throw InvalidModelError.transaction
        }
        
        self.bracketId = bracketId
        self.userId = dict["user_id"] as? Int
        self.tournamentId = tournamentId
        self.name = name
        
        if let roundArrays = dict["rounds"] as? [[[String: Any]]] {
            var tmpRounds = [[MatchHelper]]()
            for roundArray in roundArrays {
                var tmpMatches = [MatchHelper]()
                for matchDict in roundArray {
                    tmpMatches.append(try MatchHelper(dict: matchDict))
                }
                tmpRounds.append(tmpMatches)
            }
            rounds = tmpRounds
        }
    }
}

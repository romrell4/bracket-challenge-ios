//
//  Bracket.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/1/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

private let BRACKET_ID_KEY = "bracket_id"
private let USER_ID_KEY = "user_id"
private let TOURNAMENT_ID_KEY = "tournament_id"
private let NAME_KEY = "name"
private let ROUNDS_KEY = "rounds"

class Bracket {
    var bracketId: Int
    var userId: Int?
    var tournamentId: Int
    var name: String
    var rounds: [[MatchHelper]]?
    
    init(dict: [String: Any]) throws {
        guard let bracketId = dict[BRACKET_ID_KEY] as? Int, let tournamentId = dict[TOURNAMENT_ID_KEY] as? Int, let name = dict[NAME_KEY] as? String else {
            throw InvalidModelError.transaction
        }
        
        self.bracketId = bracketId
        self.userId = dict[USER_ID_KEY] as? Int
        self.tournamentId = tournamentId
        self.name = name
        
        if let roundArrays = dict[ROUNDS_KEY] as? [[[String: Any]]] {
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
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            BRACKET_ID_KEY: bracketId,
            TOURNAMENT_ID_KEY: tournamentId,
            NAME_KEY: name
        ]
        
        //Add optional properties
        if let userId = userId {
            dict[USER_ID_KEY] = userId
        }
        if let rounds = rounds {
            var rounds_array = [[[String: Any]]]()
            for round in rounds {
                var round_array = [[String: Any]]()
                for match in round {
                    round_array.append(match.toDict())
                }
                rounds_array.append(round_array)
            }
            dict[ROUNDS_KEY] = rounds_array
        }
        return dict
    }
}

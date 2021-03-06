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
private let SCORE_KEY = "score"
private let ROUNDS_KEY = "rounds"

private let UNSAVED_BRACKET_KEY_PREFIX = "UNSAVED_BRACKET_"

class Bracket {
    var bracketId: Int
    var userId: Int?
    var tournamentId: Int
    var name: String
    var score: Int
    var rounds: [[MatchHelper]]?
	
	var unsavedBracketKey: String { return "\(UNSAVED_BRACKET_KEY_PREFIX)\(bracketId)" }
    
    convenience init(dict: [String: Any]) throws {
        guard let bracketId = dict[BRACKET_ID_KEY] as? Int, let tournamentId = dict[TOURNAMENT_ID_KEY] as? Int, let name = dict[NAME_KEY] as? String, let score = dict[SCORE_KEY] as? Int else {
            throw InvalidModelError.bracket
        }
		
		var rounds: [[MatchHelper]]?
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
		self.init(bracketId: bracketId, userId: dict[USER_ID_KEY] as? Int, tournamentId: tournamentId, name: name, score: score, rounds: rounds)
    }
	
	init(bracketId: Int = 0, userId: Int? = nil, tournamentId: Int = 0, name: String = "", score: Int = 0, rounds: [[MatchHelper]]? = nil) {
		self.bracketId = bracketId
		self.userId = userId
		self.tournamentId = tournamentId
		self.name = name
		self.score = score
		self.rounds = rounds
	}
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            BRACKET_ID_KEY: bracketId,
            TOURNAMENT_ID_KEY: tournamentId,
            NAME_KEY: name,
            SCORE_KEY: score
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

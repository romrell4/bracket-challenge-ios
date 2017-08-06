//
//  Tournament.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/31/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class Tournament {
    var tournamentId: Int
    var name: String
    var masterBracketId: Int?
    
    init(dict: [String: Any]) throws {
        guard let tournamentId = dict["tournament_id"] as? Int,
            let name = dict["name"] as? String else {
                throw InvalidModelError.transaction
        }

        self.tournamentId = tournamentId
        self.name = name
        self.masterBracketId = dict["master_bracket_id"] as? Int
    }
}

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
    var image: UIImage?
    
    init(dict: [String: Any]) throws {
        guard let tournamentId = dict["tournament_id"] as? Int,
            let name = dict["name"] as? String else {
                throw InvalidModelError.transaction
        }

        self.tournamentId = tournamentId
        self.name = name
        self.masterBracketId = dict["master_bracket_id"] as? Int
        if let imageUrl = dict["image_url"] as? String, let url = URL(string: imageUrl), let data = try? Data(contentsOf: url) {
            self.image = UIImage(data: data)
        }
    }
}

//
//  Tournament.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/31/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class Tournament {
    private enum Keys: String {
        case tournamentId = "tournament_id"
        case name
        case masterBracketId = "master_bracket_id"
        case imageUrl = "image_url"
        case active
    }
    
    var tournamentId: Int
    var name: String
    var masterBracketId: Int?
    private var imageUrl: String?
    var image: UIImage?
    var active: Bool
    
    init(dict: [String: Any]) throws {
        guard let tournamentId = dict[Keys.tournamentId.rawValue] as? Int,
            let name = dict[Keys.name.rawValue] as? String,
            let active = dict[Keys.active.rawValue] as? Bool else {
                throw InvalidModelError.transaction
        }

        self.tournamentId = tournamentId
        self.name = name
        self.masterBracketId = dict[Keys.masterBracketId.rawValue] as? Int
        self.imageUrl = dict[Keys.imageUrl.rawValue] as? String
        if let imageUrl = self.imageUrl, let url = URL(string: imageUrl), let data = try? Data(contentsOf: url) {
            self.image = UIImage(data: data)
        }
        self.active = active
    }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            Keys.tournamentId.rawValue: tournamentId,
            Keys.name.rawValue: name,
            Keys.active.rawValue: active
        ]
        
        //Add optional properties
        if let masterBracketId = masterBracketId {
            dict[Keys.masterBracketId.rawValue] = masterBracketId
        }
        if let imageUrl = imageUrl {
            dict[Keys.imageUrl.rawValue] = imageUrl
        }
        return dict
    }
}

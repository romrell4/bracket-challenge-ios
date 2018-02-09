//
//  Tournament.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/31/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class Tournament {
    struct Keys {
        static let tournamentId = "tournament_id"
        static let name = "name"
        static let masterBracketId = "master_bracket_id"
        static let drawsUrl = "draws_url"
        static let imageUrl = "image_url"
        static let active = "active"
    }
    
    var tournamentId: Int
    var name: String
    var masterBracketId: Int?
    private var drawsUrl: String?
    private var imageUrl: String?
    var image: UIImage?
    var active: Bool
	
	var imageNotificationName: Notification.Name {
		return Notification.Name(rawValue: "T\(tournamentId)_IMAGE_LOADED")
	}
    
    init(dict: [String: Any]) throws {
        guard let tournamentId = dict[Keys.tournamentId] as? Int,
            let name = dict[Keys.name] as? String,
            let active = dict[Keys.active] as? Bool else {
                throw InvalidModelError.transaction
        }

        self.tournamentId = tournamentId
        self.name = name
        self.masterBracketId = dict[Keys.masterBracketId] as? Int
        self.drawsUrl = dict[Keys.drawsUrl] as? String
        self.imageUrl = dict[Keys.imageUrl] as? String
        self.active = active
		
		//Asynchronously load the image
		DispatchQueue.global(qos: .background).async {
			if let imageUrl = self.imageUrl, let url = URL(string: imageUrl), let data = try? Data(contentsOf: url) {
				self.image = UIImage(data: data)
				NotificationCenter.default.post(Notification(name: self.imageNotificationName))
			}
		}
	}
    
    func toDict() -> [String: Any] {
        //Add required properties
        var dict: [String: Any] = [
            Keys.tournamentId: tournamentId,
            Keys.name: name,
            Keys.active: active
        ]
        
        //Add optional properties
        if let masterBracketId = masterBracketId {
            dict[Keys.masterBracketId] = masterBracketId
        }
        if let drawsUrl = drawsUrl {
            dict[Keys.drawsUrl] = drawsUrl
        }
        if let imageUrl = imageUrl {
            dict[Keys.imageUrl] = imageUrl
        }
        return dict
    }
}

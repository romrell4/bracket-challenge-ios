//
//  Tournament.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/31/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

private let DATE_FORMAT = DateFormatter.defaultDateFormat("MM/dd/yyyy HH:mm:ss")

class Tournament {
    private struct Keys {
        static let tournamentId = "tournament_id"
        static let name = "name"
        static let masterBracketId = "master_bracket_id"
        static let drawsUrl = "draws_url"
        static let imageUrl = "image_url"
        static let active = "active"
        static let startDate = "start_date"
        static let endDate = "end_date"
    }
    
    var tournamentId: Int!
    var name: String?
    var masterBracketId: Int?
    var drawsUrl: String?
    var imageUrl: String?
    var startDate: Date?
    var endDate: Date?
    
    var image: UIImage?
    var active: Bool {
        if let startDate = startDate {
            return Date() < startDate
        }
        return false
    }
	
	var imageNotificationName: Notification.Name {
		return Notification.Name(rawValue: "T\(tournamentId)_IMAGE_LOADED")
	}
    
    init(tournamentId: Int? = nil, name: String? = nil, masterBracketId: Int? = nil, drawsUrl: String? = nil, imageUrl: String? = nil, startDate: Date? = nil, endDate: Date? = nil) {
        self.tournamentId = tournamentId
        self.name = name
        self.masterBracketId = masterBracketId
        self.drawsUrl = drawsUrl
        self.imageUrl = imageUrl
        self.startDate = startDate
        self.endDate = endDate
        
        //Asynchronously load the image
        DispatchQueue.global(qos: .background).async {
            if let imageUrl = self.imageUrl, let url = URL(string: imageUrl), let data = try? Data(contentsOf: url) {
                self.image = UIImage(data: data)
                NotificationCenter.default.post(Notification(name: self.imageNotificationName))
            }
        }
    }
    
    convenience init(dict: [String: Any]) throws {
        guard let tournamentId = dict[Keys.tournamentId] as? Int,
            let name = dict[Keys.name] as? String else {
                throw InvalidModelError.transaction
        }
        
        self.init(tournamentId: tournamentId,
                  name: name,
                  masterBracketId: dict[Keys.masterBracketId] as? Int,
                  drawsUrl: dict[Keys.drawsUrl] as? String,
                  imageUrl: dict[Keys.imageUrl] as? String,
                  startDate: DATE_FORMAT.date(from: dict[Keys.startDate] as? String),
                  endDate: DATE_FORMAT.date(from: dict[Keys.endDate] as? String))
	}
    
    func toDict() -> [String: Any] {
        //Add required properties
        var dict: [String: Any] = [
            Keys.name: name,
            Keys.active: active
        ]
        
        //Add optional properties
        if let tournamentId = tournamentId {
            dict[Keys.tournamentId] = tournamentId
        }
        if let masterBracketId = masterBracketId {
            dict[Keys.masterBracketId] = masterBracketId
        }
        if let drawsUrl = drawsUrl {
            dict[Keys.drawsUrl] = drawsUrl
        }
        if let imageUrl = imageUrl {
            dict[Keys.imageUrl] = imageUrl
        }
        if let startDate = startDate {
            dict[Keys.startDate] = DATE_FORMAT.string(from: startDate)
        }
        if let endDate = endDate {
            dict[Keys.endDate] = DATE_FORMAT.string(from: endDate)
        }
        return dict
    }
}

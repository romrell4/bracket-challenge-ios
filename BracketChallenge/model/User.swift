//
//  User.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class User {
    var userId: Int
    var username: String
    var name: String
    var admin: Bool = false
    
    init(dict: [String: Any]) throws {
        guard let userId = dict["user_id"] as? Int,
            let username = dict["username"] as? String,
            let name = dict["name"] as? String,
            let admin = dict["admin"] as? Bool else {
                throw InvalidModelError.user
        }
        
        self.userId = userId
        self.username = username
        self.name = name
        self.admin = admin
    }
}

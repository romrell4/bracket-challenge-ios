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
    
    init(dict: [String: Any]) {
        userId = dict["user_id"] as? Int ?? 0
        username = dict["username"] as? String ?? ""
        name = dict["name"] as? String ?? ""
    }
}

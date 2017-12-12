//
//  Identity.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/5/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import Foundation

private let USER_KEY = "USER_KEY"

class Identity {
	static var user: User! {
		didSet {
			if let data = try? JSONEncoder().encode(user) {
				UserDefaults.standard.set(data, forKey: USER_KEY)
			}
		}
	}
	
	static func loadFromDefaults() -> Bool {
		if let data = UserDefaults.standard.data(forKey: USER_KEY), let tmp = try? JSONDecoder().decode(User.self, from: data) {
			user = tmp
			return true
		} else {
			return false
		}
	}
}

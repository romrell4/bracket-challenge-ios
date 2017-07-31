//
//  BCResponse.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class BCResponse {
    var data: Data?
    var response: HTTPURLResponse?
    var error: BCError?
    
    var succeeded: Bool {
        if let response = response {
            return (200...299 ~= response.statusCode) // ~= is a pattern-matching operator
        }
        
        return error != nil
    }
    
    init(data: Data?, response: HTTPURLResponse?, error: Error?) {
        self.data = data
        self.response = response
        
        if !self.succeeded {
            if let dict = getDataJson() as? [String: Any], let readableMessage = dict["message"] as? String {
                self.error = BCError(error: error, readableMessage: readableMessage)
            } else {
                self.error = BCError(error: error, debugMessage: getDataString())
            }
        }
    }
    
    init(error: BCError?) {
        self.error = error
    }
    
    //MARK: Public functions
    
    func getDataJson() -> Any? {
        guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        
        return json
    }
    
    func getDataString() -> String? {
        guard let data = data else { return nil }
        
        return String(data: data, encoding: .utf8)
    }
}

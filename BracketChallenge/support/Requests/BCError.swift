//
//  BCError.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

private let DEFAULT_ERROR_MESSAGE = "The server encountered an error. Please try again later."

class BCError: CustomStringConvertible {
    var error: Error?
    var readableMessage: String
    var debugMessage: String?
    var description: String {
        return "Error: \(String(describing: error))\nReadable Message: \(readableMessage)\nDebug Message: \(String(describing: debugMessage))"
    }
    
    init(error: Error? = nil, readableMessage: String = DEFAULT_ERROR_MESSAGE, debugMessage: String? = nil) {
        self.error = error
        self.readableMessage = readableMessage
        self.debugMessage = debugMessage
    }
}

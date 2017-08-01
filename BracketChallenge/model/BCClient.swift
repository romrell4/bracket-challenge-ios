//
//  BCClient.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import FacebookCore

private let BASE_URL = "https://3vxcifd2rc.execute-api.us-west-2.amazonaws.com/PROD/"

class BCClient {
    static func login(callback: @escaping (User?, BCError?) -> Void) {
        makeRequest(endpoint: "users", method: "POST") { (response) in
            if response.succeeded, let dict = response.getDataJson() as? [String: Any] {
                callback(User(dict: dict), nil)
            } else {
                callback(nil, response.error)
            }
        }
    }
    
    static func getTournaments(callback: @escaping ([Tournament]?, BCError?) -> Void) {
        makeRequest(endpoint: "tournaments") { (response) in
            if response.succeeded, let array = response.getDataJson() as? [[String: Any]] {
                callback(array.map({ Tournament(dict: $0) }), nil)
            } else {
                callback(nil, response.error)
            }
        }
    }
    
    static func getBracket(tournamentId: Int, bracketId: Int, callback: @escaping (Bracket?, BCError?) -> Void) {
        makeRequest(endpoint: "/tournaments/\(tournamentId)/brackets/\(bracketId)") { (response) in
            if response.succeeded, let dict = response.getDataJson() as? [String: Any] {
                callback(Bracket(dict: dict), nil)
            } else {
                callback(nil, response.error)
            }
        }
    }
    
    private static func makeRequest(endpoint: String, method: String = "GET", completionHandler: @escaping ((BCResponse) -> Void)) {
        let urlString = "\(BASE_URL)\(endpoint)"
        guard let url = URL(string: urlString) else {
            completionHandler(BCResponse(error: BCError(readableMessage: "Invalid URL: \(urlString)")))
            return
        }
        guard let token = AccessToken.current?.authenticationToken else {
            completionHandler(BCResponse(error: BCError(readableMessage: "No valid token. Please log out and back in.")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue(token, forHTTPHeaderField: "Token")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            OperationQueue.main.addOperation {
                let bcResponse = BCResponse(data: data, response: response as? HTTPURLResponse, error: error)
                if !bcResponse.succeeded {
                    print("Error: \(bcResponse.error?.description ?? "")")
                }
                completionHandler(bcResponse)
            }
        }.resume()
    }
}

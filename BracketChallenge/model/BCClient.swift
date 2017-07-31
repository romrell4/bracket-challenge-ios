//
//  BCClient.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

private let BASE_URL = "https://3vxcifd2rc.execute-api.us-west-2.amazonaws.com/PROD/"

class BCClient {
    static func login(username: String, callback: @escaping (User?, BCError?) -> Void) {
        makeRequest(endpoint: "login/\(username)", method: "POST") { (response) in
            if response.succeeded, let dict = response.getDataJson() as? [String: Any] {
                callback(User(dict: dict), nil)
            } else {
                callback(nil, response.error)
            }
        }
    }
    
    private static func makeRequest(endpoint: String, method: String, completionHandler: @escaping ((BCResponse) -> Void)) {
        guard let url = URL(string: "\(BASE_URL)\(endpoint)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = method
        
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

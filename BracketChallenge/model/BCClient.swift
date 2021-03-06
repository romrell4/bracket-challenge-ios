//
//  BCClient.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import FirebaseAuth

private let BASE_URL = "https://3vxcifd2rc.execute-api.us-west-2.amazonaws.com/PROD/"

class BCClient {
    static func login(callback: @escaping (User?, BCError?) -> Void) {
        makeRequest(endpoint: "users", method: "POST") { (response) in
            if response.succeeded, let dict = response.getDataJson() as? [String: Any] {
                do {
                    callback(try User(dict: dict), nil)
                } catch {
                    callback(nil, BCError(readableMessage: "Invalid user returned from service"))
                }
            } else {
                callback(nil, response.error)
            }
        }
    }
    
    static func getPlayers(callback: @escaping ([Player]?, BCError?) -> Void) {
        makeRequest(endpoint: "players") { (response) in
            if response.succeeded, let array = response.getDataJson() as? [[String: Any]] {
                do {
                    callback(try array.map { try Player(dict: $0) }, nil)
                } catch {
                    callback(nil, BCError(readableMessage: "Invalid player returned from service"))
                }
            } else {
                callback(nil, response.error)
            }
        }
    }
    
    static func getTournaments(callback: @escaping ([Tournament]?, BCError?) -> Void) {
        makeRequest(endpoint: "tournaments") { (response) in
            if response.succeeded, let array = response.getDataJson() as? [[String: Any]] {
                do {
                    callback(try array.map { try Tournament(dict: $0) }, nil)
                } catch {
                    callback(nil, BCError(readableMessage: "Invalid tournament returned from service"))
                }
            } else {
                callback(nil, response.error)
            }
        }
    }
    
    static func saveTournament(tournament: Tournament, callback: @escaping (Tournament?, BCError?) -> Void) {
		let (url, method): (String, String)
		if let tournamentId = tournament.tournamentId {
			(url, method) = ("tournaments/\(tournamentId)", "PUT")
		} else {
			(url, method) = ("tournaments", "POST")
		}
		
		makeRequest(endpoint: url, method: method, body: tournament.toDict()) { (response) in
            if response.succeeded, let dict = response.getDataJson() as? [String: Any] {
                do {
                    callback(try Tournament(dict: dict), nil)
                } catch {
                    callback(nil, BCError(readableMessage: "Invalid tournament returned from service"))
                }
            } else {
                callback(nil, response.error)
            }
        }
    }
    
    static func updateTournament(_ tournament: Tournament, callback: @escaping (Tournament?, BCError?) -> Void) {
		guard let tournamentId = tournament.tournamentId else {
			callback(nil, BCError(readableMessage: "You cannot update a tournament without a tournament id"))
			return
		}
        makeRequest(endpoint: "tournaments/\(tournamentId)", method: "PUT", body: tournament.toDict()) { (response) in
            if response.succeeded, let dict = response.getDataJson() as? [String: Any] {
                do {
                    callback(try Tournament(dict: dict), nil)
                } catch {
                    callback(nil, BCError(readableMessage: "Invalid tournament returned from service"))
                }
            } else {
                callback(nil, response.error)
            }
        }
    }
	
	static func deleteTournament(_ tournamentId: Int, callback: @escaping (BCError?) -> Void) {
		makeRequest(endpoint: "tournaments/\(tournamentId)", method: "DELETE") { (response) in
			if response.succeeded {
				callback(nil)
			} else {
				callback(response.error)
			}
		}
	}
    
    static func getBrackets(tournamentId: Int, callback: @escaping ([Bracket]?, BCError?) -> Void) {
        makeRequest(endpoint: "tournaments/\(tournamentId)/brackets") { (response) in
            if response.succeeded, let array = response.getDataJson() as? [[String: Any]] {
                do {
                    callback(try array.map { try Bracket(dict: $0) }, nil)
                } catch {
                    callback(nil, BCError(readableMessage: "Invalid bracket returned from service"))
                }
            } else {
                callback(nil, response.error)
            }
        }
    }
    
    static func getMyBracket(tournamentId: Int, callback: @escaping (Bool, Bracket?, BCError?) -> Void) {
        makeRequest(endpoint: "tournaments/\(tournamentId)/brackets/mine") { (response) in
            if response.succeeded, let dict = response.getDataJson() as? [String: Any] {
                do {
                    callback(true, try Bracket(dict: dict), nil)
                } catch {
                    callback(false, nil, BCError(readableMessage: "Invalid bracket returned from service"))
                }
            } else {
                //If the status code was 404, the response is valid, but the user didn't have a bracket
                callback(response.response?.statusCode == 404, nil, response.error)
            }
        }
    }

    static func getBracket(tournamentId: Int, bracketId: Int, callback: @escaping (Bracket?, BCError?) -> Void) {
        makeRequest(endpoint: "tournaments/\(tournamentId)/brackets/\(bracketId)") { (response) in
            if response.succeeded, let dict = response.getDataJson() as? [String: Any] {
                do {
                    callback(try Bracket(dict: dict), nil)
                } catch {
                    callback(nil, BCError(readableMessage: "Invalid bracket returned from service"))
                }
            } else {
                callback(nil, response.error)
            }
        }
    }
    
    static func createBracket(tournamentId: Int, bracketName: String? = nil, callback: @escaping (Bracket?, BCError?) -> Void) {
        makeRequest(endpoint: "tournaments/\(tournamentId)/brackets", method: "POST", body: ["name": bracketName ?? "Tester"]) { (response) in
            if response.succeeded, let dict = response.getDataJson() as? [String: Any] {
                do {
                    callback(try Bracket(dict: dict), nil)
                } catch {
                    callback(nil, BCError(readableMessage: "Invalid bracket returned from service"))
                }
            } else {
                callback(nil, response.error)
            }
        }
    }
    
    static func updateBracket(bracket: Bracket, callback: @escaping (Bracket?, BCError?) -> Void) {
        makeRequest(endpoint: "tournaments/\(bracket.tournamentId)/brackets/\(bracket.bracketId)", method: "PUT", body: bracket.toDict()) { (response) in
            if response.succeeded, let dict = response.getDataJson() as? [String: Any] {
                do {
                    callback(try Bracket(dict: dict), nil)
                } catch {
                    callback(nil, BCError(readableMessage: "Invalid bracket returned from service"))
                }
            } else {
                callback(nil, response.error)
            }
        }
    }
    
    static func refreshMasterBracket(tournamentId: Int, callback: @escaping (Bracket?, BCError?) -> Void) {
        makeRequest(endpoint: "tournaments/\(tournamentId)/scrape", method: "POST") { (response) in
            if response.succeeded, let dict = response.getDataJson() as? [String: Any] {
                do {
                    callback(try Bracket(dict: dict), nil)
                } catch {
                    callback(nil, BCError(readableMessage: "Invalid bracket returned from service"))
                }
            } else {
                callback(nil, response.error)
            }
        }
    }
    
    private static func makeRequest(endpoint: String, method: String = "GET", body: Any? = nil, completionHandler: @escaping ((BCResponse) -> Void)) {
        let urlString = "\(BASE_URL)\(endpoint)"
        guard let url = URL(string: urlString) else {
            completionHandler(BCResponse(error: BCError(readableMessage: "Invalid URL: \(urlString)")))
            return
        }
		Auth.auth().currentUser?.getIDToken { (token, error) in
			guard let token = token else {
				completionHandler(BCResponse(error: BCError(readableMessage: "Unable to obtain authentication token. Please log in.", debugMessage: error.debugDescription)))
				return
			}
			var request = URLRequest(url: url)
			request.httpMethod = method
			request.addValue(token, forHTTPHeaderField: "x-firebase-token")
			if let body = body {
				request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
			}
			
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
}

enum InvalidModelError: Error {
    case user
    case player
	case tournament
    case bracket
    case match
}

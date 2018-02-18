//
//  TournamentsViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

private let TOURNAMENT_SEGUE_ID = "tournament"
private let CREATE_MASTER_SEGUE_ID = "createMaster"

class TournamentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
    //MARK: Public properties
    var tournaments = [Tournament]()
	
	//MARK: Private properties
	private var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		if AccessToken.current != nil, Identity.loadFromDefaults() {
			loggedIn(segue: nil)
		} else {
			LoginManager().logOut()
			performSegue(withIdentifier: "logIn", sender: nil)
		}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TOURNAMENT_SEGUE_ID, let vc = segue.destination as? TournamentTabBarViewController, let tournament = sender as? Tournament {
            vc.tournament = tournament
        }
    }
    
    //MARK: UITableViewDataSource callbacks
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournaments.count
    }
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 120
	}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(for: indexPath) as? TournamentTableViewCell {
			cell.tournament = tournaments[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    //MARK: UITableViewDelegate callbacks
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tournament = tournaments[indexPath.row]
        if tournament.masterBracketId != nil {
            performSegue(withIdentifier: TOURNAMENT_SEGUE_ID, sender: tournament)
        } else {
            //If the draw hasn't been released, this tournament cannot be accessed yet
            super.displayAlert(title: "Tournament Unavailable", message: "The draws for this tournament have not yet been published. Brackets cannot be made until the draw is complete.", alertHandler: { (_) in
                tableView.deselectRow(at: indexPath, animated: true)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if Identity.user.admin {
            let tournament = tournaments[indexPath.row]
            
            let refreshAction = UITableViewRowAction(style: .normal, title: "Refresh", handler: { (_, _) in
                self.spinner.startAnimating()
                BCClient.refreshMasterBracket(tournamentId: self.tournaments[indexPath.row].tournamentId) { bracket, error in
                    if let bracket = bracket {
                        //If the call succeeded, and the master bracket didn't exist, set the master bracket id
                        if tournament.masterBracketId == nil {
                            tournament.masterBracketId = bracket.bracketId
                        }
                    } else {
                        self.spinner.stopAnimating()
                        super.displayAlert(error: error, title: "Failed to refresh")
                    }
                }
            })
            refreshAction.backgroundColor = .purple
            
            let activateAction = UITableViewRowAction(style: .normal, title: tournament.active ? "Deactivate" : "Activate", handler: { (_, _) in
                tournament.active = !tournament.active
                BCClient.updateTournament(tournament) { (tournament, error) in
                    if let tournament = tournament {
                        self.tournaments[indexPath.row] = tournament
                    }
                }
            })
            activateAction.backgroundColor = tournament.active ? .red : .blue
            
            return [refreshAction, activateAction]
        }
        return []
    }
    
    //MARK: Listeners
	
	@IBAction func logOut(_ sender: UIBarButtonItem) {
		LoginManager().logOut()
		performSegue(withIdentifier: "logIn", sender: nil)
	}
	
	@IBAction func loggedIn(segue: UIStoryboardSegue?) {
		title = Identity.user.name
		
		//If they are an admin, they can create tournaments. Give them the button
		if Identity.user.admin {
			navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(_:)))
		}
		
		setupTableView()
		loadTournaments(nil)
	}
    
    @objc func addTapped(_ sender: Any) {
        //Display pop up allowing them to type the name of the new tournament
        let alert = UIAlertController(title: "New Tournament", message: "Please enter the name of the tournament below", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Tournament Name"
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .words
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Draw URL (optional)"
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }
		alert.addTextField { (textField) in
			textField.placeholder = "Image URL (optional)"
			textField.autocorrectionType = .no
			textField.autocapitalizationType = .none
		}
        alert.addAction(UIAlertAction(title: "Create", style: .default) { (action: UIAlertAction) in
			guard let name = alert.textFields?[0].text, let drawsUrl = alert.textFields?[1].text, let imageUrl = alert.textFields?[2].text else { return }
			
			self.spinner.startAnimating()
            BCClient.createTournament(name: name, drawsUrl: drawsUrl, imageUrl: imageUrl, callback: { (tournament, error) in
				self.spinner.stopAnimating()
				if let tournament = tournament {
					self.tournaments.insert(tournament, at: 0)
					self.tableView.reloadData()
				} else {
					super.displayAlert(error: error, alertHandler: nil)
				}
			})
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
	
	@objc func loadTournaments(_ sender: Any?) {
		//If a sender is passed in, this is a refresh. Otherwise, it's the first load
		sender == nil ? spinner.startAnimating() : refreshControl.beginRefreshing()
		BCClient.getTournaments { (tournaments, error) in
			self.spinner.stopAnimating()
			self.refreshControl.endRefreshing()
			if let tournaments = tournaments {
				self.tournaments = tournaments
				self.tableView.reloadData()
			} else {
				super.displayAlert(error: error)
			}
		}
	}
    
    //MARK: Private functions
    
    private func setupTableView() {
		refreshControl = tableView.addDefaultRefreshControl(target: self, action: #selector(loadTournaments(_:)))
        tableView.hideEmptyCells()
        tableView.registerNib(nibName: "TournamentTableViewCell")
        tableView.variableHeightForRows()
    }
}

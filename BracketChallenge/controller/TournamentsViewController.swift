//
//  TournamentsViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit
import FirebaseAuth

private let TOURNAMENT_SEGUE_ID = "tournament"
private let ADD_EDIT_SEGUE_ID = "addEditTournament"

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
		
		if Identity.loadFromDefaults() {
			//If the user was logged in previously, start the data load
			self.loggedIn()
		}
		
		Auth.auth().addStateDidChangeListener { (_, user) in
			if user != nil {
				//If the are currently logged out, log them in
				if Identity.user == nil {
					BCClient.login { (user, error) in
						if let user = user {
							Identity.user = user
							self.loggedIn()
						} else {
							self.displayAlert(error: error)
						}
					}
				}
			} else {
				self.presentLoginViewController()
			}
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
		} else if segue.identifier == ADD_EDIT_SEGUE_ID, let navVc = segue.destination as? UINavigationController, let vc = navVc.viewControllers.first as? AddEditTournamentViewController {
			vc.tournament = sender as? Tournament
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
	
	@available(iOS 11.0, *)
	func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		if Identity.user?.admin == true {
			return UISwipeActionsConfiguration(actions: [UIContextualAction(style: .destructive, title: "Delete", handler: { (_, _, completionHandler) in
				self.spinner.startAnimating()
				
				let tournament = self.tournaments[indexPath.row]
				BCClient.deleteTournament(tournament.tournamentId, callback: { (error) in
					self.spinner.stopAnimating()
					if error == nil {
						self.tournaments.remove(at: indexPath.row)
						self.tableView.deleteRows(at: [indexPath], with: .automatic)
						completionHandler(true)
					} else {
						self.displayAlert(error: error)
						completionHandler(false)
					}
				})
			})])
		}
		return nil
	}
	
	@available(iOS 11.0, *)
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		if Identity.user?.admin == true {
			return UISwipeActionsConfiguration(actions: [
				UIContextualAction(style: .normal, title: "Edit", color: .blue) { (_, _, _) in
					self.performSegue(withIdentifier: ADD_EDIT_SEGUE_ID, sender: self.tournaments[indexPath.row])
				},
				UIContextualAction(style: .normal, title: "Refresh", color: .purple) { (_, _, _) in
					self.spinner.startAnimating()
					
					let tournament = self.tournaments[indexPath.row]
					BCClient.refreshMasterBracket(tournamentId: tournament.tournamentId) { bracket, error in
						self.spinner.stopAnimating()
						if let bracket = bracket {
							//If the call succeeded, and the master bracket didn't exist, set the master bracket id
							if tournament.masterBracketId == nil {
								tournament.masterBracketId = bracket.bracketId
							}
						} else {
							super.displayAlert(error: error, title: "Failed to refresh")
						}
					}
				}
			])
		}
		return nil
	}
    
    //MARK: Listeners
	
	@IBAction func logOut(_ sender: UIBarButtonItem) {
		try? Auth.auth().signOut()
		Identity.user = nil
		presentLoginViewController()
	}
	    
    @IBAction func tournamentAdded(segue: UIStoryboardSegue?) {
        if let vc = segue?.source as? AddEditTournamentViewController, let tournament = vc.tournament {
			if let existingIndex = tournaments.firstIndex(where: { $0.tournamentId == tournament.tournamentId }) {
				tournaments[existingIndex] = tournament
			} else {
				tournaments.insert(tournament, at: 0)
			}
        }
		tableView.reloadData()
    }
    
    @objc func addTapped(_ sender: Any) {
        performSegue(withIdentifier: ADD_EDIT_SEGUE_ID, sender: nil)
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
	
	private func loggedIn() {
		guard let user = Identity.user else { return }
		//If they are an admin, they can create tournaments. Give them the button
		if user.admin {
			navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(_:)))
		}
		
		setupTableView()
		loadTournaments(nil)
	}
    
    private func setupTableView() {
		refreshControl = tableView.addDefaultRefreshControl(target: self, action: #selector(loadTournaments(_:)))
        tableView.hideEmptyCells()
        tableView.registerNib(nibName: "TournamentTableViewCell")
        tableView.variableHeightForRows()
    }
}

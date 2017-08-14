//
//  TournamentsViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit
import FacebookLogin

private let SEGUE_ID = "tournament"

class TournamentsViewController: BCViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Outlets
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: Public properties
    var tournaments = [Tournament]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Identity.user.name
        if Identity.user.admin {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(_:)))
        }
        
        setupTableView()
        loadTournaments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Don't all the user to go back from here, unless they logout
        navigationItem.setHidesBackButton(true, animated: false)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE_ID, let vc = segue.destination as? TournamentTabBarViewController, let tournament = sender as? Tournament {
            vc.tournament = tournament
        }
    }
    
    //MARK: UITableViewDataSource callbacks
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournaments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TournamentTableViewCell {
            cell.setTournament(tournaments[indexPath.row])
            return cell
        }
        
        return UITableViewCell()
    }
    
    //MARK: UITableViewDelegate callbacks
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tournament = tournaments[indexPath.row]
        if tournament.masterBracketId != nil {
            performSegue(withIdentifier: SEGUE_ID, sender: tournament)
        } else if Identity.user.admin {
            let dialog = UIAlertController(title: "Master Bracket Not Created", message: "This tournament does not yet have a master bracket. Would you like to create one?", preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                //TODO: Add logic to create master bracket
            }))
            dialog.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            present(dialog, animated: true, completion: { 
                tableView.deselectRow(at: indexPath, animated: true)
            })
        } else {
            super.displayAlert(title: "Tournament Unavailable", message: "The draws for this tournament have not yet been published. Brackets cannot be made until the draw is complete.", alertHandler: { (_) in
                tableView.deselectRow(at: indexPath, animated: true)
            })
        }
    }
    
    //MARK: Listeners
    
    @IBAction func logoutTapped(_ sender: Any) {
        LoginManager().logOut()
        navigationController?.popViewController(animated: true)
    }
    
    func addTapped(_ sender: Any) {
        let alert = UIAlertController(title: "New Tournament", message: "Please enter the name of the tournament below", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Tournament Name"
            textField.autocapitalizationType = .words
        })
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action: UIAlertAction) in
            if let name = alert.textFields?.first?.text {
                BCClient.createTournament(name: name, callback: { (tournament, error) in
                    if let tournament = tournament {
                        //TODO: Test this once we have the endpoint created
                        self.tournaments.append(tournament)
                        self.tableView.reloadData()
                    } else {
                        super.displayAlert(error: error, alertHandler: nil)
                    }
                })
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Private functions
    
    func setupTableView() {
        tableView.hideEmptyCells()
        tableView.registerNib(nibName: "TournamentTableViewCell")
        tableView.variableHeightForRows()
    }
    
    func loadTournaments() {
        BCClient.getTournaments { (tournaments, error) in
            if let tournaments = tournaments {
                self.tournaments = tournaments
                self.tableView.reloadData()
            } else {
                super.displayAlert(error: error)
            }
        }
    }
}

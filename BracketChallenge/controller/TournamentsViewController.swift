//
//  TournamentsViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit
import FacebookLogin

private let TOURNAMENT_SEGUE_ID = "tournament"
private let CREATE_MASTER_SEGUE_ID = "createMaster"

class TournamentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
    //MARK: Public properties
    var tournaments = [Tournament]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Identity.user.name
        
        //If they are an admin, they can create tournaments. Give them the button
        if Identity.user.admin {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(_:)))
        }
        
        setupTableView()
        loadTournaments()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(for: indexPath) as? TournamentTableViewCell {
            cell.setTournament(tournaments[indexPath.row])
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
    
    //MARK: Listeners
    
    @IBAction func logoutTapped(_ sender: Any) {
        LoginManager().logOut()
        super.popBack()
    }
    
    func addTapped(_ sender: Any) {
        //Display pop up allowing them to type the name of the new tournament
        let alert = UIAlertController(title: "New Tournament", message: "Please enter the name of the tournament below", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Tournament Name"
            textField.autocapitalizationType = .words
        })
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action: UIAlertAction) in
            if let name = alert.textFields?.first?.text {
                self.spinner.startAnimating()
                BCClient.createTournament(name: name, callback: { (tournament, error) in
                    self.spinner.stopAnimating()
                    if let tournament = tournament {
                        self.tournaments.append(tournament)
                        self.tableView.reloadData()
                    } else {
                        super.displayAlert(error: error, alertHandler: nil)
                    }
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Private functions
    
    private func setupTableView() {
        tableView.hideEmptyCells()
        tableView.registerNib(nibName: "TournamentTableViewCell")
        tableView.variableHeightForRows()
    }
    
    private func loadTournaments() {
        spinner.startAnimating()
        BCClient.getTournaments { (tournaments, error) in
            self.spinner.stopAnimating()
            if let tournaments = tournaments {
                self.tournaments = tournaments
                self.tableView.reloadData()
            } else {
                super.displayAlert(error: error)
            }
        }
    }
}

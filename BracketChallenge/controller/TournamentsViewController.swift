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
        setupTableView()
        
        loadData()
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
            //TODO: Add logic to create the master bracket
        } else {
            super.displayAlert(title: "Bracket Unavailable", message: "The draws for this tournament have not yet been published. Brackets cannot be made until the draw is complete.", alertHandler: { (_) in
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
        }
    }
    
    //MARK: Listeners
    
    @IBAction func logoutTapped(_ sender: Any) {
        LoginManager().logOut()
        navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Private functions
    
    func setupTableView() {
        tableView.hideEmptyCells()
        tableView.registerNib(nibName: "TournamentTableViewCell")
        tableView.variableHeightForRows()
    }
    
    func loadData() {
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

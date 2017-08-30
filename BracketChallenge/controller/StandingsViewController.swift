//
//  StandingsViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/28/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class StandingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    //Public properties
    var tournament: Tournament!
    
    //Private properties
    private var brackets = [Bracket]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.hideEmptyCells()
        
        loadBrackets()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userBracket", let vc = segue.destination as? UserBracketViewController, let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            vc.tournament = tournament
            vc.userBracket = brackets[indexPath.row]
        }
    }
    
    //MARK: UITableViewDataSource/Delegate callbacks
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brackets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bracket = brackets[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(for: indexPath)
        cell.textLabel?.text = bracket.name
        cell.detailTextLabel?.text = "\(bracket.score)"
        return cell
    }
    
    //MARK: Private functions
    
    private func loadBrackets() {
        BCClient.getBrackets(tournamentId: tournament.tournamentId) { (brackets, error) in
            self.spinner.stopAnimating()
            if let brackets = brackets {
                self.brackets = brackets.filter { $0.bracketId != self.tournament.masterBracketId }
                self.tableView.reloadData()
            } else {
                super.displayAlert(error: error)
            }
        }
    }
}

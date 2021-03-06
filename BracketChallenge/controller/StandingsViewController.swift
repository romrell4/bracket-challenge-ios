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
    var masterBracket: Bracket?
    
    //Private properties
    private var brackets = [Bracket]()
	private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.hideEmptyCells()
		refreshControl = tableView.addDefaultRefreshControl(target: self, action: #selector(loadBrackets))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		loadBrackets()
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userBracket", let vc = segue.destination as? UserBracketViewController, let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            vc.tournament = tournament
            vc.bracket = brackets[indexPath.row]
            vc.masterBracket = masterBracket
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
    
    //MARK: Listeners
    
    @objc func loadBrackets() {
		refreshControl.beginRefreshing()
        BCClient.getBrackets(tournamentId: tournament.tournamentId) { (brackets, error) in
            self.spinner.stopAnimating()
			self.refreshControl.endRefreshing()
            if let brackets = brackets {
                self.brackets = brackets.filter { $0.bracketId != self.tournament.masterBracketId }
                self.tableView.reloadData()
            } else {
                super.displayAlert(error: error)
            }
        }
    }
}

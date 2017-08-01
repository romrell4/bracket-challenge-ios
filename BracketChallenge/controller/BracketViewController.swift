//
//  BracketViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/31/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class BracketViewController: BCViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Public properties
    var tournamentId: Int!
    var bracketId: Int!
    
    //MARK: Private properties
    private var bracket: Bracket?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.hideEmptyCells()
        
        loadBracket()
    }
    
    //MARK: UITableViewDelegate/Datasource callbacks
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return bracket?.matches?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Match: \(bracket?.matches?[section].position ?? 0)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let match = bracket?.matches?[indexPath.section]
        let player = indexPath.row == 0 ? match?.player1Name : match?.player2Name
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = player
        return cell
    }
    
    //MARK: Listeners
    
    @IBAction func swipeLeft(_ sender: Any) {
        print("Swiped Left")
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        print("Swiped Right")
    }
    
    //MARK: Private functions
    
    private func loadBracket() {
        BCClient.getBracket(tournamentId: tournamentId, bracketId: bracketId) { (bracket, error) in
            if let bracket = bracket {
                self.bracket = bracket
                self.tableView.reloadData()
            } else {
                super.displayAlert(error: error)
            }
        }
    }
}

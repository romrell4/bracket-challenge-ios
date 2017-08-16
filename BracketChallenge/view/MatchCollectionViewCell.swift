//
//  MatchCollectionViewCell.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/12/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

let TABLE_CELL_HEIGHT: CGFloat = 44

class MatchCollectionViewCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Public properties
    var match: MatchHelper? {
        didSet {
            tableView.reloadData()
        }
    }
    var players: [Player]?
    
    override func awakeFromNib() {
        layer.borderColor = UIColor.bcGreen.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 8
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(nibName: "MatchTableViewCell")
        tableView.registerNib(nibName: "CreateMatchTableViewCell", forCellIdentifier: "cell2")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TABLE_CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if players == nil, let cell = tableView.dequeueReusableCell(for: indexPath) as? MatchTableViewCell {
            if indexPath.row == 0 {
                cell.nameLabel.text = match?.player1Full
                cell.accessoryType = match?.winnerId != nil && match?.winnerId == match?.player1Id ? .checkmark : .none
            } else {
                cell.nameLabel.text = match?.player2Full
                cell.accessoryType = match?.winnerId != nil && match?.winnerId == match?.player2Id ? .checkmark : .none
            }
            return cell
        } else if let players = players, let cell = tableView.dequeueReusableCell(for: indexPath, withId: "cell2") as? CreateMatchTableViewCell {
            cell.players = players
            return cell
        }
        return UITableViewCell()
    }
}

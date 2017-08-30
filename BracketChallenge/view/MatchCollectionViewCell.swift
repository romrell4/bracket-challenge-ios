//
//  MatchCollectionViewCell.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/12/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

let TABLE_CELL_HEIGHT: CGFloat = 44

protocol MatchCollectionViewCellDelegate {
    func player(_ player: Player?, selectedInCell cell: MatchCollectionViewCell)
}

class MatchCollectionViewCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate, MatchTableViewCellDelegate {
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Public properties
    var match: MatchHelper? {
        didSet {
            tableView.reloadData()
        }
    }
    var masterMatch: MatchHelper? {
        didSet {
            tableView.reloadData()
        }
    }
    var delegate: MatchCollectionViewCellDelegate?
    var players: [Player]?
    var areCellsClickable = true
    
    override func awakeFromNib() {
        layer.borderColor = UIColor.bcGreen.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 8
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(nibName: "MatchTableViewCell")
        tableView.registerNib(nibName: "CreateMatchTableViewCell", forCellIdentifier: "cell2")
    }
    
    //UITableViewDataSource/Delegate callbacks
    
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
                cell.isUserInteractionEnabled = match?.player1 != nil
                cell.nameLabel.textColor = textColorFor(playerId: match?.player1Id, predictionId: match?.winnerId, winnerId: masterMatch?.winnerId)
            } else {
                cell.nameLabel.text = match?.player2Full
                cell.accessoryType = match?.winnerId != nil && match?.winnerId == match?.player2Id ? .checkmark : .none
                cell.isUserInteractionEnabled = match?.player2 != nil
                cell.nameLabel.textColor = textColorFor(playerId: match?.player2Id, predictionId: match?.winnerId, winnerId: masterMatch?.winnerId)
            }
            cell.delegate = self
            return cell
        } else if let players = players, let cell = tableView.dequeueReusableCell(for: indexPath, withId: "cell2") as? CreateMatchTableViewCell {
            cell.players = players
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if areCellsClickable {
            let otherIndexPath = IndexPath(row: indexPath.row == 0 ? 1 : 0, section: indexPath.section)
            if let cell = tableView.cellForRow(at: indexPath) as? MatchTableViewCell, let otherCell = tableView.cellForRow(at: otherIndexPath) as? MatchTableViewCell {
                cell.checked = true
                otherCell.checked = false
            }
        }
    }
    
    //MatchTableViewCellDelegate callback
    
    func selected(cell: MatchTableViewCell) {
        if let row = tableView.indexPath(for: cell)?.row {
            let player = row == 0 ? match?.player1 : match?.player2
            delegate?.player(player, selectedInCell: self)
        }
    }
    
    //Private functions
    
    func textColorFor(playerId: Int?, predictionId: Int?, winnerId: Int?) -> UIColor {
        if playerId == nil || winnerId == nil || predictionId == nil {
            return .black
        } else if predictionId == playerId {
            if winnerId == playerId {
                return .winnerGreen
            } else {
                return .red
            }
        } else {
            if winnerId == playerId {
                return .black
            } else {
                return .lightGray
            }
        }
    }
}

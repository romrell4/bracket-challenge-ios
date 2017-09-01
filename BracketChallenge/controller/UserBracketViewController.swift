//
//  UserBracketViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/28/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class UserBracketViewController: BracketViewController {
    
    //Public properties
    var userBracket: Bracket? {
        didSet {
            loadIfReady()
        }
    }
    var masterBracket: Bracket? {
        didSet {
            loadIfReady()
        }
    }
    
    //MARK: Overrides
    
    override func areCellsClickable() -> Bool {
        return false
    }
    
    //MARK: UICollectionViewDataSource callbacks
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        if let matchCell = cell as? MatchCollectionViewCell, let masterBracket = masterBracket {
            matchCell.masterMatch = super.getMatches(for: collectionView, from: masterBracket)[indexPath.row]
        }
        return cell
    }
    
    //Private functions
    
    private func loadIfReady() {
        if let bracket = userBracket, masterBracket != nil {
            super.spinner.stopAnimating()
            super.bracket = bracket
        }
    }
}

//
//  MyBracketViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/6/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class MyBracketViewController: BracketViewController, UITabBarDelegate {
    //MARK: Outlets
    @IBOutlet weak var createBracketView: UIView!
    
    //MARK: Private properties
    private var masterBracket: Bracket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let masterBracketId = super.tournament.masterBracketId else {
            //They should not be here if there is no master bracket yet
            super.popBack()
            return
        }
        
        BCClient.getBracket(tournamentId: super.tournament.tournamentId, bracketId: masterBracketId) { (masterBracket, error) in
            if let masterBracket = masterBracket {
                self.masterBracket = masterBracket
            } else {
                super.displayAlert(error: error)
            }
        }
        
        loadMyBracket()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateBracket))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    //MARK: Listeners
    
    override func areCellsClickable() -> Bool {
        return tournament.active
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        if let matchCell = cell as? MatchCollectionViewCell, let masterBracket = masterBracket {
            matchCell.masterMatch = super.getMatches(for: collectionView, from: masterBracket)[indexPath.row]
        }
        return cell
    }
    
    @IBAction func createBracketTapped(_ sender: Any) {
        super.spinner.startAnimating()
        BCClient.createBracket(tournamentId: super.tournament.tournamentId, bracketName: Identity.user.name) { (bracket, error) in
            super.spinner.stopAnimating()
            self.createBracketView.isHidden = true
            if let bracket = bracket {
                super.bracket = bracket
            } else {
                super.displayAlert(error: error)
            }
        }
    }
    
    //MARK: Private functions
    
    private func loadMyBracket() {
        BCClient.getMyBracket(tournamentId: super.tournament.tournamentId, callback: { (validResponse, bracket, error) in
            super.spinner.stopAnimating()
            if validResponse {
                if let bracket = bracket {
                    super.bracket = bracket
                } else {
                    self.createBracketView.isHidden = false
                    self.view.bringSubview(toFront: self.createBracketView)
                }
            } else {
                super.displayAlert(error: error)
            }
        })
    }
}

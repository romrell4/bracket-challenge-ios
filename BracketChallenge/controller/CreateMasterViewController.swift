//
//  CreateMasterViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/14/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

protocol CreateMasterBracketDelegate {
    func bracketCreated()
}

class CreateMasterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
    //MARK: Public properties
    var tournament: Tournament!
    var delegate: CreateMasterBracketDelegate!
    
    //MARK: Private properties
    private var matches = [MatchHelper]()
    private var players: [Player]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.registerNib(nibName: "MatchCollectionViewCell")
        
        loadPlayers()
    }
    
    //MARK: UICollectionViewDataSource/DelegateFlowLayout callbacks
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //If the players haven't loaded yet, don't load the matches
        return players == nil ? 0 : matches.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - CELL_INSET * 2, height: TABLE_CELL_HEIGHT * 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: CELL_INSET, left: CELL_INSET, bottom: CELL_INSET, right: CELL_INSET)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MatchCollectionViewCell, let players = players {
            cell.players = players
            return cell
        }
        return UICollectionViewCell()
    }
    
    //MARK: Listeners
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Warning", message: "Any players in red will create a new player in the database. Are you sure you'd like to create a new master bracket with these entries?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (_) in
            self.spinner.startAnimating()
            BCClient.createBracket(tournamentId: self.tournament.tournamentId, callback: { (bracket, error) in
                self.spinner.stopAnimating()
                if bracket != nil {
                    self.delegate.bracketCreated()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    super.displayAlert(error: error, alertHandler: nil)
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: Private functions
    
    private func loadPlayers() {
        BCClient.getPlayers { (players, error) in
            self.spinner.stopAnimating()
            if let players = players {
                self.players = players
                self.collectionView.reloadData()
            } else {
                super.displayAlert(error: error)
            }
        }
    }
}

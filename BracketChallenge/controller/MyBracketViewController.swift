//
//  MyBracketViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/6/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class MyBracketViewController: UserBracketViewController, UITabBarControllerDelegate {
    //MARK: Outlets
    @IBOutlet weak var createBracketView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.delegate = self
        
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateBracket))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    //MARK: UITabBarController callbacks
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return bracket != nil && masterBracket != nil
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let vc = viewController as? ResultsViewController, vc.bracket == nil {
            vc.bracket = masterBracket
        } else if let vc = viewController as? StandingsViewController, vc.masterBracket == nil {
            vc.masterBracket = masterBracket
        }
    }
    
    //MARK: Listeners
    
    override func areCellsClickable() -> Bool {
        return tournament.active
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
    
    private func loadData() {
        guard let masterBracketId = super.tournament.masterBracketId else {
            //They should not be here if there is no master bracket yet
            super.popBack()
            return
        }
        
        BCClient.getMyBracket(tournamentId: super.tournament.tournamentId, callback: { (validResponse, bracket, error) in
            super.spinner.stopAnimating()
            if validResponse {
                if let bracket = bracket {
                    super.userBracket = bracket
                } else {
                    self.createBracketView.isHidden = false
                    self.view.bringSubview(toFront: self.createBracketView)
                }
            } else {
                super.displayAlert(error: error)
            }
        })
        BCClient.getBracket(tournamentId: super.tournament.tournamentId, bracketId: masterBracketId) { (masterBracket, error) in
            if let masterBracket = masterBracket {
                self.masterBracket = masterBracket
            } else {
                super.displayAlert(error: error)
            }
        }
    }
}

//
//  MyBracketViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/6/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class MyBracketViewController: BracketViewController {
    //MARK: Outlets
    @IBOutlet weak var createBracketView: UIView!
    
    //MARK: Private properties
    private var saveButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateBracket))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Start off disabled (until the data comes back)
        saveButton.isEnabled = false
        
        BCClient.getMyBracket(tournamentId: super.tournament.tournamentId, callback: { (validResponse, bracket, error) in
            super.spinner.stopAnimating()
            if validResponse {
                if let bracket = bracket {
                    super.bracket = bracket
                    
                    //Depending on whether the button
                    if let saveButton = self.tabBarController?.navigationItem.rightBarButtonItem {
                        saveButton.isEnabled = true
                    } else {
                        self.saveButton.isEnabled = true
                    }
                } else {
                    self.createBracketView.isHidden = false
                    self.view.bringSubview(toFront: self.createBracketView)
                }
            } else {
                super.displayAlert(error: error)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.navigationItem.rightBarButtonItem = saveButton
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    //MARK: Listeners
    
    @IBAction func createBracketTapped(_ sender: Any) {
        super.spinner.startAnimating()
        BCClient.createBracket(tournamentId: super.tournament.tournamentId) { (bracket, error) in
            super.spinner.stopAnimating()
            self.createBracketView.isHidden = true
            if let bracket = bracket {
                super.bracket = bracket
            } else {
                super.displayAlert(error: error)
            }
        }
    }
    
    func updateBracket() {
        if let bracket = bracket {
            BCClient.updateBracket(bracket: bracket, callback: { (bracket, error) in
                if let bracket = bracket {
                    self.bracket = bracket
                } else {
                    super.displayAlert(error: error)
                }
            })
        }
    }
}

//
//  BracketViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/31/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class BracketViewController: BCViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    //MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    //MARK: Public properties
    var tournament: Tournament!
    var bracket: Bracket?
    
    //MARK: Private properties
    private var tableViews = [UITableView]()
    private var roundIndex = 0
    
    //MARK: UIScrollViewDelegate callbacks
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //Test the offset and calculate the current page after scrolling ends
        roundIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        
        //Change the indicator
        pageControl.currentPage = roundIndex
        tableViews[roundIndex].reloadData()
    }
    
    //MARK: UITableViewDelegate/Datasource callbacks
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return getMatches(for: tableView).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let match = getMatches(for: tableView)[indexPath.section]
        print(indexPath)
        if indexPath.row == 0, let cell = tableView.dequeueReusableCell(withIdentifier: "topCell", for: indexPath) as? MatchTableViewCell {
            cell.nameLabel.text = match.player1Full
            //TODO: Figure out style for winner (different for MyBracket and Results)
//            cell.backgroundColor = match.winnerId == match.player1Id ? .yellow : .white
//            cell.accessoryType = match.winnerId == match.player1Id ? .checkmark : .none
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "bottomCell", for: indexPath) as? MatchTableViewCell {
            cell.nameLabel.text = match.player2Full
//            cell.backgroundColor = match.winnerId == match.player2Id ? .yellow : .white
//            cell.accessoryType = match.winnerId == match.player2Id ? .checkmark : .none
            return cell
        }
        return UITableViewCell()
    }
    
    //MARK: Public functions
    
    func loadBracket(bracketId: Int) {
        BCClient.getBracket(tournamentId: tournament.tournamentId, bracketId: bracketId) { (bracket, error) in
            self.spinner.stopAnimating()
            if let bracket = bracket {
                self.bracket = bracket
                self.setupTableViews()
            } else {
                super.displayAlert(error: error)
            }
        }
    }
    
    func setupTableViews() {
        let width = Double(scrollView.frame.width)
        let height = Double(scrollView.frame.height)
        
        let rounds = bracket?.rounds?.count ?? 1
        for round in 0...(rounds - 1) {
            let tableView = UITableView(frame: CGRect(x: Double(round) * width, y: 0.0, width: width, height: height))
            tableView.delegate = self
            tableView.dataSource = self
            tableView.hideEmptyCells()
            tableView.registerNib(nibName: "TopMatchTableViewCell", forCellIdentifier: "topCell")
            tableView.registerNib(nibName: "BottomMatchTableViewCell", forCellIdentifier: "bottomCell")
            tableView.separatorStyle = .none
            tableViews.append(tableView)
            scrollView.addSubview(tableView)
        }
        scrollView.contentSize = CGSize(width: width * Double(rounds), height: height)
        pageControl.currentPage = 0
        pageControl.numberOfPages = rounds
    }
    
    //MARK: Private functions
    
    private func getMatches(for tableView: UITableView) -> [MatchHelper] {
        guard let round = tableViews.index(of: tableView), let matches = bracket?.rounds?[round] else { return [] }
        return matches
    }
}

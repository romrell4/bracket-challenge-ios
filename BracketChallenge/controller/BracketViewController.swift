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
    
    //MARK: Public properties
    var tournamentId: Int!
    var bracketId: Int?
    
    //MARK: Private properties
    private var tableViews = [UITableView]()
    private var bracket: Bracket?
    private var roundIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBracket()
    }
    
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? BracketMatchTableViewCell {
            let match = getMatches(for: tableView)[indexPath.section]
            let playerId = indexPath.row == 0 ? match.player1Id : match.player2Id
            cell.nameLabel.text = indexPath.row == 0 ? match.player1Full : match.player2Full
            cell.accessoryType = match.winnerId == playerId ? .checkmark : .none
            return cell
        }
        return UITableViewCell()
    }
    
    //MARK: Private functions
    
    private func setupTableViews() {
        let width = Double(scrollView.frame.width)
        let height = Double(scrollView.frame.height)
        
        let rounds = bracket?.rounds?.count ?? 0
        for round in 0...rounds - 1 {
            let tableView = UITableView(frame: CGRect(x: Double(round) * width, y: 0.0, width: Double(round + 1) * width, height: height))
            tableView.delegate = self
            tableView.dataSource = self
            tableView.hideEmptyCells()
            tableView.registerNib(nibName: "BracketMatchTableViewCell")
            tableView.separatorStyle = .none
            tableViews.append(tableView)
            scrollView.addSubview(tableView)
        }
        scrollView.contentSize = CGSize(width: width * Double(rounds), height: height)
        pageControl.currentPage = 0
        pageControl.numberOfPages = rounds
    }
    
    private func loadBracket() {
        if let bracketId = bracketId {
            BCClient.getBracket(tournamentId: tournamentId, bracketId: bracketId) { (bracket, error) in
                if let bracket = bracket {
                    self.bracket = bracket
                    self.setupTableViews()
                } else {
                    super.displayAlert(error: error)
                }
            }
        }
    }
    
    private func getMatches(for tableView: UITableView) -> [MatchHelper] {
        guard let round = tableViews.index(of: tableView), let matches = bracket?.rounds?[round] else { return [] }
        return matches
    }
}

//
//  BracketViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/12/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

let CELL_INSET: CGFloat = 8

class BracketViewController: BCViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MatchCollectionViewCellDelegate {
    //Public properties
    var spinner: UIActivityIndicatorView!
    var tournament: Tournament!
    var bracket: Bracket? {
        didSet {
            tabBarController?.title = bracket?.name
            setupCollectionViews()
        }
    }
    
    //Private properties
    private var scrollView: UIScrollView!
    private var collectionViews = [UICollectionView]()
    private var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.title = bracket?.name
    }
        
    //UIScrollViewDelegate callbacks
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //Test the offset and calculate the current page after scrolling ends
        let roundIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        
        //Change the indicator
        pageControl.currentPage = roundIndex
        collectionViews[roundIndex].reloadData()
    }
    
    //UICollectionViewDataSource/DelegateFlowLayout callbacks
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getMatches(for: collectionView).count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - CELL_INSET * 2, height: TABLE_CELL_HEIGHT * 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: CELL_INSET, left: CELL_INSET, bottom: CELL_INSET, right: CELL_INSET)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MatchCollectionViewCell {
            cell.match = getMatches(for: collectionView)[indexPath.row]
            cell.delegate = self
            return cell
        }
        return UICollectionViewCell()
    }
    
    //MatchCollectionViewCell callbacks
    
    func player(_ player: Player?, selectedInCell cell: MatchCollectionViewCell) {
        for round in 0...collectionViews.count {
            guard let position = collectionViews[round].indexPath(for: cell)?.row else { continue }
            bracket?.rounds?[round][position].winner = player
            
            //Update the next round
            let nextRound = round + 1
            let newPosition = position / 2 //Integer division will automatically do a "floor"
            if nextRound < collectionViews.count {
                let match = bracket?.rounds?[nextRound][newPosition]
                if position % 2 == 0 {
                    match?.player1 = player
                } else {
                    match?.player2 = player
                }
                collectionViews[round + 1].reloadData()
            }
            return
        }
    }
    
    //Public functions
    
    func loadBracket(bracketId: Int) {
        spinner.startAnimating()
        BCClient.getBracket(tournamentId: tournament.tournamentId, bracketId: bracketId) { (bracket, error) in
            self.spinner.stopAnimating()
            if let bracket = bracket {
                self.bracket = bracket
            } else {
                super.displayAlert(error: error)
            }
        }
    }
    
    func updateBracket() {
        if let bracket = bracket {
            spinner.startAnimating()
            BCClient.updateBracket(bracket: bracket, callback: { (bracket, error) in
                self.spinner.stopAnimating()
                if let bracket = bracket {
                    self.bracket = bracket
                    super.displayAlert(title: "Success", message: "Bracket successfully updated", alertHandler: nil)
                } else {
                    super.displayAlert(error: error)
                }
            })
        }
    }
    
    func areCellsClickable() -> Bool {
        //Override if you want to stop users from selecting the rows
        return true
    }
    
    //Private functions
    
    private func createUI() {
        createScrollView()
        createPageControl()
        createSpinner()
    }
    
    private func createScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        view.addSubview(scrollView)
        view.addConstraints([
            NSLayoutConstraint(item: view, attr1: .leading, toItem: scrollView, attr2: .leading),
            NSLayoutConstraint(item: view, attr1: .trailing, toItem: scrollView, attr2: .trailing),
            NSLayoutConstraint(item: view, attr1: .top, toItem: scrollView, attr2: .top),
            NSLayoutConstraint(item: bottomLayoutGuide, attr1: .top, toItem: scrollView, attr2: .bottom)
        ])
    }
    
    private func createPageControl() {
        pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .bcGreen
        pageControl.pageIndicatorTintColor = .bcYellow
        view.addSubview(pageControl)
        view.addConstraints([
            NSLayoutConstraint(item: view, attr1: .centerX, toItem: pageControl, attr2: .centerX),
            NSLayoutConstraint(item: view, attr1: .bottom, toItem: pageControl, attr2: .bottom, constant: 50)
        ])
    }
    
    private func createSpinner() {
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .bcGreen
        spinner.startAnimating()
        view.addSubview(spinner)
        view.addConstraints([
            NSLayoutConstraint(item: view, attr1: .centerX, toItem: spinner, attr2: .centerX),
            NSLayoutConstraint(item: view, attr1: .centerY, toItem: spinner, attr2: .centerY)
        ])
    }
    
    private func setupCollectionViews() {
        //Remove all the current collectionViews (as they will be replaced)
        for collectionView in collectionViews {
            collectionView.removeFromSuperview()
        }
        collectionViews.removeAll(keepingCapacity: false)
        
        let width = Double(scrollView.frame.width)
        let height = Double(scrollView.frame.height)
        
        let rounds = bracket?.rounds?.count ?? 1
        for round in 0...(rounds - 1) {
            let collectionView = UICollectionView(frame: CGRect(x: Double(round) * width, y: 0.0, width: width, height: height), collectionViewLayout: UICollectionViewFlowLayout())
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = .lightGray
            collectionView.isUserInteractionEnabled = areCellsClickable()
            collectionView.registerNib(nibName: "MatchCollectionViewCell")
            collectionViews.append(collectionView)
            scrollView.addSubview(collectionView)
        }
        scrollView.contentSize = CGSize(width: width * Double(rounds), height: height)
        pageControl.numberOfPages = rounds
    }
    
    private func getMatches(for collectionView: UICollectionView) -> [MatchHelper] {
        if let round = collectionViews.index(of: collectionView) {
            let rounds = bracket?.rounds ?? []
            if rounds.count > round {
                return rounds[round]
            }
        }
        return []
    }
}

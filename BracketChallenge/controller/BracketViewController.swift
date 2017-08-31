//
//  BracketViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/12/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

let CELL_INSET: CGFloat = 8

class BracketViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MatchCollectionViewCellDelegate {
    //Public properties
    var spinner: UIActivityIndicatorView!
    var tournament: Tournament!
    var bracket: Bracket? {
        didSet {
            //Sometimes, this will be set before viewDidLoad is called. If that is the case, wait for the viewDidLoad to load the UI
            if isViewLoaded {
                loadUI()
            }
        }
    }
    
    //Private properties
    private var pageControl: UIPageControl!
    private var scoreLabel: UILabel!
    private var scrollView: UIScrollView!
    private var collectionViews = [UICollectionView]()
    
    //Used for calculating the page control
    private var oldPoint = CGPoint()
    private var horizontalScroll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createUI()
        
        //If the bracket was set before this was called, load the bracket UI now
        if bracket != nil {
            loadUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //When this tab is selectd, reset the title to the bracket name
        tabBarController?.title = bracket?.name
    }
        
    //UIScrollViewDelegate callbacks
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Check if they are scrolling horizontally
        let newPoint = scrollView.contentOffset
        horizontalScroll = newPoint.y == oldPoint.y
        oldPoint = newPoint
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //Only change the pageControl if they scrolled horizontally
        if horizontalScroll {
            //Test the offset and calculate the current page after scrolling ends
            let roundIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
            
            //Change the indicator
            pageControl.currentPage = roundIndex
        }
    }
    
    //UICollectionViewDataSource/DelegateFlowLayout callbacks
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getMatches(for: collectionView, from: self.bracket).count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //Each cell shoud be the width of the view (minus padding) and the height of two cells
        return CGSize(width: collectionView.frame.width - CELL_INSET * 2, height: TABLE_CELL_HEIGHT * 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //Add some padding between cells
        return UIEdgeInsets(top: CELL_INSET, left: CELL_INSET, bottom: CELL_INSET, right: CELL_INSET)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(for: indexPath) as? MatchCollectionViewCell {
            cell.areCellsClickable = self.areCellsClickable()
            cell.match = getMatches(for: collectionView, from: bracket)[indexPath.row]
            cell.delegate = self //This will notify us when matches are selected
            return cell
        }
        return UICollectionViewCell()
    }
    
    //MatchCollectionViewCell callbacks
    
    func player(_ player: Player?, selectedInCell cell: MatchCollectionViewCell) {
        for round in 0...collectionViews.count {
            //If the cell selected wasn't in this round, continue searching
            guard var indexPath = collectionViews[round].indexPath(for: cell) else { continue }
            let position = indexPath.row
            
            //Set the winner
            bracket?.rounds?[round][position].winner = player
            
            //Reload the UI for this match
            collectionViews[round].reloadItems(at: [indexPath])
            
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
                
                //Reload the UI for the next match
                indexPath.row = newPosition
                collectionViews[round + 1].reloadItems(at: [indexPath])
            }
            
            //If you found it, don't keep looking
            return
        }
    }
    
    //Public functions
    
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
    
    func getMatches(for collectionView: UICollectionView, from bracket: Bracket?) -> [MatchHelper] {
        //Find the round that the collectionView belongs to and return the corresponding matches
        if let round = collectionViews.index(of: collectionView) {
            let rounds = bracket?.rounds ?? []
            if rounds.count > round {
                return rounds[round]
            }
        }
        return []
    }
    
    //Private functions
    
    private func createUI() {
        view.backgroundColor = .lightGray
        createTopView()
        createSpinner()
    }
    
    private func createTopView() {
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topView)
        view.addConstraints([
            NSLayoutConstraint(item: view, attr1: .leading, toItem: topView, attr2: .leading),
            NSLayoutConstraint(item: view, attr1: .trailing, toItem: topView, attr2: .trailing),
            NSLayoutConstraint(item: topLayoutGuide, attr1: .bottom, toItem: topView, attr2: .top),
            NSLayoutConstraint(item: topView, attr1: .height, constant: 32)
        ])
        pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .bcGreen
        pageControl.pageIndicatorTintColor = .bcYellow
        topView.addSubview(pageControl)
        topView.addConstraints([
            NSLayoutConstraint(item: topView, attr1: .centerX, toItem: pageControl, attr2: .centerX),
            NSLayoutConstraint(item: topView, attr1: .centerY, toItem: pageControl, attr2: .centerY)
        ])
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.font = UIFont.systemFont(ofSize: 18)
        topView.addSubview(scoreLabel)
        topView.addConstraints([
            NSLayoutConstraint(item: topView, attr1: .trailingMargin, toItem: scoreLabel, attr2: .trailing),
            NSLayoutConstraint(item: topView, attr1: .centerY, toItem: scoreLabel, attr2: .centerY)
        ])
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.isDirectionalLockEnabled = true
        scrollView.isPagingEnabled = true
        view.addSubview(scrollView)
        view.addConstraints([
            NSLayoutConstraint(item: view, attr1: .leading, toItem: scrollView, attr2: .leading),
            NSLayoutConstraint(item: view, attr1: .trailing, toItem: scrollView, attr2: .trailing),
            NSLayoutConstraint(item: topView, attr1: .bottom, toItem: scrollView, attr2: .top),
            NSLayoutConstraint(item: view, attr1: .bottom, toItem: scrollView, attr2: .bottom, constant: 50)
        ])
    }
    
    private func createSpinner() {
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .bcGreen
        view.addSubview(spinner)
        view.addConstraints([
            NSLayoutConstraint(item: view, attr1: .centerX, toItem: spinner, attr2: .centerX),
            NSLayoutConstraint(item: view, attr1: .centerY, toItem: spinner, attr2: .centerY)
        ])
    }
    
    private func loadUI() {
        navigationItem.title = bracket?.name
        tabBarController?.navigationItem.title = bracket?.name
        scoreLabel.text = "Score: \(bracket?.score ?? 0)"
        setupCollectionViews()
    }
    
    private func setupCollectionViews() {
        //Remove all the current collectionViews (as they will be replaced)
        for collectionView in collectionViews {
            collectionView.removeFromSuperview()
        }
        collectionViews.removeAll(keepingCapacity: false)
        
        let width = scrollView.frame.width
        let height = scrollView.frame.height
        
        let rounds = bracket?.rounds?.count ?? 1
        for _ in 0...(rounds - 1) {
            let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = .lightGray
            collectionView.registerNib(nibName: "MatchCollectionViewCell")
            scrollView.addSubview(collectionView)
            scrollView.addConstraints([
                NSLayoutConstraint(item: scrollView, attr1: .top, toItem: collectionView, attr2: .top),
                NSLayoutConstraint(item: collectionView, attr1: .height, constant: height),
                NSLayoutConstraint(item: collectionView, attr1: .width, constant: scrollView.frame.width)
            ])
            
            //Check how to constrain your leading edge
            if let previous = collectionViews.last {
                //If there is a previous collectionView, constrain to it's trailing edge
                scrollView.addConstraint(NSLayoutConstraint(item: previous, attr1: .trailing, toItem: collectionView, attr2: .leading))
            } else {
                //If you're the first, constraint to the leading edge of the scrollView
                scrollView.addConstraint(NSLayoutConstraint(item: scrollView, attr1: .leading, toItem: collectionView, attr2: .leading))
            }
            collectionViews.append(collectionView)
        }
        scrollView.contentSize = CGSize(width: width * CGFloat(rounds), height: height)
        pageControl.numberOfPages = rounds
    }
}

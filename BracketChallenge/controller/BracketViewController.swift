//
//  BracketViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/12/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

private let CELL_INSET: CGFloat = 8

class BracketViewController: BCViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //Public properties
    var spinner: UIActivityIndicatorView!
    var tournament: Tournament!
    var bracket: Bracket? {
        didSet {
            tabBarController?.title = bracket?.name
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
        
    //UIScrollViewDelegate callbacks
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //Test the offset and calculate the current page after scrolling ends
        let roundIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        
        //Change the indicator
        pageControl.currentPage = roundIndex
        collectionViews[roundIndex].reloadData()
    }
    
    //UICollectionViewDataSource/Delegate callbacks
    
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
            return cell
        }
        return UICollectionViewCell()
    }
    
    //Public functions
    
    func loadBracket(bracketId: Int) {
        BCClient.getBracket(tournamentId: tournament.tournamentId, bracketId: bracketId) { (bracket, error) in
            self.spinner.stopAnimating()
            if let bracket = bracket {
                self.bracket = bracket
                self.setupCollectionViews()
            } else {
                super.displayAlert(error: error)
            }
        }
    }
    
    func setupCollectionViews() {
        let width = Double(scrollView.frame.width)
        let height = Double(scrollView.frame.height)
        
        let rounds = bracket?.rounds?.count ?? 1
        for round in 0...(rounds - 1) {
            let collectionView = UICollectionView(frame: CGRect(x: Double(round) * width, y: 0.0, width: width, height: height), collectionViewLayout: UICollectionViewFlowLayout())
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = .lightGray
            collectionView.registerNib(nibName: "MatchCollectionViewCell")
            collectionViews.append(collectionView)
            scrollView.addSubview(collectionView)
        }
        scrollView.contentSize = CGSize(width: width * Double(rounds), height: height)
        pageControl.currentPage = 0
        pageControl.numberOfPages = rounds
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
            NSLayoutConstraint(item: view, attr1: .bottom, toItem: scrollView, attr2: .bottom)
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

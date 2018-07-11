//
//  BracketViewController2.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 6/30/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class BracketViewController2: UIViewController {
	private struct UI {
		static let tableViewWidth: CGFloat = UIScreen.main.bounds.width * 0.8
		static let cellHeight: CGFloat = 180
		static let minimumPanAmount: CGFloat = UI.tableViewWidth / 4
		static let minimumPanVelocity: CGFloat = 100
		static let animateDuration = 2.0
	}
	
	//MARK: Public Properties
	var tournament: Tournament!
	var bracket: Bracket? {
		didSet {
			//Sometimes, this will be set before viewDidLoad is called. If that is the case, wait for the viewDidLoad to load the UI
			if isViewLoaded {
				loadUI()
			}
		}
	}
	
	//MARK: Private Properties
	private var contentView: UIView!
	private var panOriginX: CGFloat = 0
	private var tableViews = [UITableView]()
	private var activeTableViews: ArraySlice<UITableView> {
		return tableViews[max(currentPage - 1, 0)...min(currentPage + 1, tableViews.count - 1)]
	}
	private var currentPage = 0 {
		didSet {
			activeTableViews.filter { $0 != tableViews[currentPage] }.forEach {
				$0.contentOffset = tableViews[currentPage].contentOffset
			}
			//Redraw all table views
			activeTableViews.forEach {
				$0.beginUpdates()
				$0.endUpdates()
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if bracket != nil {
			loadUI()
		}
	}
	
	//MARK: ScrollViewDelegate
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		//Keep all visible scroll views in sync
		activeTableViews.filter { $0 != scrollView }.forEach {
			$0.contentOffset = scrollView.contentOffset
		}
	}
	
	//MARK: Listeners
	
	@objc func tapped() {
		activeTableViews.forEach {
			$0.reloadData()
		}
		printOffsets()
	}
	
	@objc func panGestureHandler(recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .began:
			panOriginX = recognizer.view?.frame.origin.x ?? 0
		case .changed:
			let translation = recognizer.translation(in: contentView)
			recognizer.view?.frame.origin.x = panOriginX + translation.x
		case .ended:
			//Animate the cells growing and/or shrinking
			UIView.animate(withDuration: UI.animateDuration, animations: {
				//Check the distance moved to determine if we should switch pages
				let translation = recognizer.translation(in: self.contentView).x
				if translation <= -UI.minimumPanAmount && self.currentPage < self.tableViews.count - 1 {
					//We're moving left (and there is another page to our right)
					self.printOffsets()
					self.currentPage += 1
				} else if translation >= UI.minimumPanAmount && self.currentPage > 0 {
					//We're moving right (and there is another page to our left)
					self.printOffsets()
					self.currentPage -= 1
				}
				recognizer.view?.frame.origin.x = 0 - (UI.tableViewWidth * CGFloat(self.currentPage))
			}) { (_) in
				self.printOffsets()
			}
		default: break
		}
	}
	
	//MARK: Custom Functions
	
	private func printOffsets() {
		let previousPosition = currentPage > 0 ? "\(tableViews[currentPage - 1].contentOffset.y)" : "nil"
		let currentPosition = tableViews[currentPage].contentOffset.y
		let nextPosition = currentPage < tableViews.count - 1 ? "\(tableViews[currentPage + 1].contentOffset.y)" : "nil"
		print("\(previousPosition) <-- \(currentPosition) --> \(nextPosition)")
	}
	
	private func loadUI() {
		//Create the content view with the correct size
		contentView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(bracket?.rounds?.count ?? 0) * UI.tableViewWidth, height: view.frame.height))
		contentView.backgroundColor = .clear
		view.addSubview(contentView)
		
		//Add the pan gesture
		let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(recognizer:)))
		contentView.addGestureRecognizer(gestureRecognizer)
		
		//Add a tap gesture
		let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
		contentView.addGestureRecognizer(tap)
		
		//Load up the tables for the rounds
		addRounds()
	}
	
	private func addRounds() {
		var nextTableViewX: CGFloat = 0
		bracket?.rounds?.forEach { (_) in
			let table = UITableView(frame: CGRect(x: nextTableViewX, y: 0, width: UI.tableViewWidth, height: view.frame.height))
			nextTableViewX += UI.tableViewWidth
			table.backgroundColor = .clear
			
			table.delegate = self
			table.dataSource = self
			table.registerNib(nibName: "RoundTableViewCell")
			table.separatorStyle = .none
			table.showsVerticalScrollIndicator = false
			
			tableViews.append(table)
			
			contentView.addSubview(table)
			
			table.reloadData()
		}
	}
}

extension BracketViewController2: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let round = tableViews.index(of: tableView), let matches = bracket?.rounds?[round] {
			return matches.count
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(for: indexPath)
		if let cell = cell as? RoundTableViewCell, let round = tableViews.index(of: tableView) {
			cell.match = bracket?.rounds?[round][indexPath.row]
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if tableView == tableViews[currentPage] {
			return UI.cellHeight
		} else if currentPage != 0 && tableView == tableViews[currentPage - 1] {
			return UI.cellHeight / 2
		} else if tableView == tableViews[currentPage + 1] {
			return UI.cellHeight * 2
		}
		return UI.cellHeight * 4
	}
}

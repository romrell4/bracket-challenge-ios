//
//  TestViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/15/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
	var scrollView = UIScrollView()
	var stackView = UIStackView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.backgroundColor = .gray
		view.addSubview(scrollView)
		
		NSLayoutConstraint.activate([
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: view.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
		
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 20
		scrollView.addSubview(stackView)
		
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
		])

		for _ in 0...100 {
			let subview = UIView()
			subview.backgroundColor = .black
			stackView.addArrangedSubview(subview)
			
			NSLayoutConstraint.activate([
				subview.heightAnchor.constraint(equalToConstant: 100)
			])
		}
	}
}

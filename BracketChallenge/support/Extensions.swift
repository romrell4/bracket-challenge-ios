//
//  Extensions.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit
import FirebaseUI

//MARK: Basic data types

extension Date {
    func next(_ dayName: String) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_US")
        
        if let index = cal.weekdaySymbols.firstIndex(of: dayName), let date = cal.nextDate(after: self, matching: DateComponents(weekday: index + 1), matchingPolicy: .nextTime) {
            return date
        }
        return self
    }
}

extension DateFormatter {
    static func defaultDateFormat(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US")
        formatter.dateFormat = format
        return formatter
    }
    
    func date(from string: String?) -> Date? {
        if let string = string {
            return self.date(from: string)
        } else {
            return nil
        }
    }
}

extension NSLayoutConstraint {
	convenience init(item: Any, attr1: NSLayoutConstraint.Attribute, relatedBy: NSLayoutConstraint.Relation = .equal, toItem: Any? = nil, attr2: NSLayoutConstraint.Attribute = .notAnAttribute, multiplier: CGFloat = 1, constant: CGFloat = 0) {
		self.init(item: item, attribute: attr1, relatedBy: relatedBy, toItem: toItem, attribute: attr2, multiplier: multiplier, constant: constant)
	}
}

extension NumberFormatter {
	convenience init(style: NumberFormatter.Style) {
		self.init()
		numberStyle = style
	}
}

extension String {
	func urlEncoded(characterSet: CharacterSet = .alphanumerics) -> String {
		return self.addingPercentEncoding(withAllowedCharacters: characterSet) ?? ""
	}
}

//MARK: UI

extension UIColor {
    
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat = 1) {
        self.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: opacity)
    }
    
    static var bcGreen: UIColor {
        return UIColor(red: 37, green: 104, blue: 0)
    }
    
    static var bcYellow: UIColor {
        return UIColor(red: 248, green: 255, blue: 52)
    }
    
    static var winnerGreen: UIColor {
        return UIColor(red: 0, green: 130, blue: 0)
    }
}

extension UITableView {
    func hideEmptyCells() {
        tableFooterView = UIView()
    }
    
    //This method will make the rows of a tableView cell automatically adjust to fit contents
    //NOTE: The number of lines on the cell's textLabel must be set to 0 for this to work.
    //This can be done programatically or from the storyboard
    func variableHeightForRows() {
        self.estimatedRowHeight = 44.0                  //Arbitrary value, set to default cell height
        self.rowHeight = UITableView.automaticDimension  //Needed to resize cells to fit contents
    }
    
    func registerNib(nibName: String, forCellIdentifier cellId: String = "cell") {
        self.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    func dequeueReusableCell(for indexPath: IndexPath, withId cellIdentifier: String = "cell") -> UITableViewCell {
        return dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    }
	
	func addDefaultRefreshControl(target: Any?, action: Selector) -> UIRefreshControl {
		let refreshControl = UIRefreshControl()
		refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
		refreshControl.addTarget(target, action: action, for: .valueChanged)
		refreshControl.beginRefreshing()
		self.addSubview(refreshControl)
		return refreshControl
	}
}

@available(iOS 11.0, *)
extension UIContextualAction {
	convenience init(style: UIContextualAction.Style, title: String?, color: UIColor, handler: @escaping UIContextualAction.Handler) {
		self.init(style: style, title: title, handler: handler)
		backgroundColor = color
	}
}

extension UICollectionView {
    func registerNib(nibName: String, forCellIndentifier cellId: String = "cell") {
        register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: cellId)
    }
    
    func dequeueReusableCell(for indexPath: IndexPath, withId cellIdentifier: String = "cell") -> UICollectionViewCell {
        return dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
    }
}

extension UIViewController {
    func displayActionSheet(from item: Any, title: String? = nil, actions: [UIAlertAction], cancelActionHandler: ((UIAlertAction?) -> Void)? = nil) {
        let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        for action in actions {
            actionSheet.addAction(action)
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancelActionHandler))
        
        if let barButton = item as? UIBarButtonItem {
            actionSheet.popoverPresentationController?.barButtonItem = barButton
        } else if let view = item as? UIView {
            actionSheet.popoverPresentationController?.sourceView = view
            actionSheet.popoverPresentationController?.sourceRect = view.bounds
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    //This function is for convenience only. Sadly, we have fought for too long to try and make "popBack" the default alertHandler for the function below... to no avail. This will have to do.
    func displayAlert(error: BCError? = nil, title: String = "Error", message: String? = nil) {
        displayAlert(error: error, title: title, message: message) { (_) in
            self.popBack()
        }
    }
    
    func displayAlert(error: BCError? = nil, title: String = "Error", message: String? = nil, alertHandler: ((UIAlertAction?) -> Void)?) {
        let alert = UIAlertController(title: title, message: message ?? error?.readableMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: alertHandler))
        present(alert, animated: true, completion: nil)
    }
    
    func popBack() {
        navigationController?.popViewController(animated: true)
    }
	
	func presentLoginViewController(loggedInListener: ((FirebaseUI.User) -> Void)? = nil) {
		if let listener = loggedInListener {
			Auth.auth().addStateDidChangeListener { (_, user) in
				if let user = user {
					listener(user)
				}
			}
		}
		
		guard let authUI = FUIAuth.defaultAuthUI() else { return }
		authUI.providers = [
			FUIGoogleAuth(),
			FUIFacebookAuth(),
			FUIEmailAuth()
		]
		present(authUI.authViewController(), animated: true)
	}
}

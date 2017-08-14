//
//  Extensions.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

//MARK: Basic data types

extension String {
    func urlEncoded(characterSet: CharacterSet = .alphanumerics) -> String {
        return self.addingPercentEncoding(withAllowedCharacters: characterSet) ?? ""
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
    convenience init(item: Any, attr1: NSLayoutAttribute, relatedBy: NSLayoutRelation = .equal, toItem: Any? = nil, attr2: NSLayoutAttribute = .notAnAttribute, multiplier: CGFloat = 1, constant: CGFloat = 0) {
        self.init(item: item, attribute: attr1, relatedBy: relatedBy, toItem: toItem, attribute: attr2, multiplier: multiplier, constant: constant)
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
        self.rowHeight = UITableViewAutomaticDimension  //Needed to resize cells to fit contents
    }
    
    func registerNib(nibName: String, forCellIdentifier cellId: String = "cell") {
        self.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    func dequeueReusableCell(for indexPath: IndexPath) -> UITableViewCell {
        return dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    }
}

extension UICollectionView {
    func registerNib(nibName: String, forCellIndentifier cellId: String = "cell") {
        register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: cellId)
    }
}

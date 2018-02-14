//
//  TableData.swift
//  byuSuite
//
//  Created by Erik Brady on 5/8/17.
//  Copyright © 2017 Brigham Young University. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class TableData: NSObject {
	
	var sections: [Section] //An array of sections
	
	var useCaching = false 			//Set this to true to cache images. Your Row objects must contain the imageUrl.
	
	var count: Int {                //The number of sections in the tableData
		return sections.count
	}
	
	//Initialize with sections, default to empty array
	init(sections: [Section] = []) {
		self.sections = sections
	}
	
	//Initialize with rows (assuming you only have one section)
	init(rows: [Row]) {
		sections = [Section(rows: rows)]
	}
	
	//Add a section
	func add(section: Section) {
		sections.append(section)
	}
	
	//Add rows to a section
	func add(rows: [Row], toSection section: Int) {
		sections[section].rows.append(contentsOf: rows)
	}
	
	//Get the cell identifier for a given indexPath
	func cellId(forIndexPath indexPath: IndexPath) -> String {
		let row = self.row(forIndexPath: indexPath)
		return row.cellId ?? sections[indexPath.section].cellId ?? "cell"
	}
	
	//Get the title for a given section
	func title(forSection section: Int) -> String? {
		return sections[section].title
	}
	
	//Get the height for a given section
	func height(forSection section: Int) -> CGFloat? {
		return sections[section].height
	}
	
	//Get the number of rows for a given section
	func numberOfRows(inSection section: Int) -> Int {
		//When numberOfSections has not been overriden, numberOfRowsInSection will be called
		//on a tableView which assumes there is one section. This will crash if you don't check.
		if section > sections.count - 1 {
			return 0
		}
		return sections[section].rows.count
	}
	
	//Get the height for a given row
	func height(forRowAtIndexPath indexPath: IndexPath) -> CGFloat? {
		return row(forIndexPath: indexPath).height
	}
	
	//Get the object for a given row
	func object<T>(forIndexPath indexPath: IndexPath) -> T? {
		return row(forIndexPath: indexPath).object as? T
	}
	
	//Get more info for a given row
	func moreInfo(forIndexPath indexPath: IndexPath) -> [String: Any]? {
		return row(forIndexPath: indexPath).moreInfo
	}
	
	//Dequeue the cell for a given row
	func dequeueCell(forTableView tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		return tableView.dequeueReusableCell(withIdentifier: cellId(forIndexPath: indexPath), for: indexPath)
	}
	
	//Set the cell for a given row
	func cell(forTableView tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		let row = self.row(forIndexPath: indexPath)
		
		let cell = dequeueCell(forTableView: tableView, atIndexPath: indexPath)
		cell.textLabel?.text = row.text
		cell.detailTextLabel?.text = row.detailText
		
		if let imageUrl = row.imageUrl {
			
			//Load image from cache if cache is enabled or load image from url.
			if useCaching, let image = imageCache[imageUrl] {
				cell.imageView?.image = image
			} else {
				loadImage(row: row, callback: { (image) in
					let cell = tableView.cellForRow(at: indexPath)
					cell?.imageView?.image = image
					cell?.setNeedsLayout()
				})
			}
		}
		
		cell.isUserInteractionEnabled = row.enabled
		return cell
	}
	
	//Execute the action for a given row if it exists
	func didSelectRow(atIndexPath indexPath: IndexPath) {
		if let action = row(forIndexPath: indexPath).action {
			action()
		}
	}
	
	//Get a specific row
	func row(forIndexPath indexPath: IndexPath) -> Row {
		return sections[indexPath.section].rows[indexPath.row]
	}
	
	//Get a list of rows in a section
	func rows(inSection section: Int) -> [Row] {
		return sections[section].rows
	}
	
	//MARK: Private Methods
	
	private func loadImage(row: Row, callback: @escaping (UIImage) -> Void) {
		if let imageUrl = row.imageUrl, let url = URL(string: imageUrl) {
			
			//Move the data load to a background thread.
			URLSession.shared.dataTask(with: url, completionHandler: { (data, _, _) in
				if let data = data, let image = UIImage(data: data) {
					if self.useCaching {
						imageCache[imageUrl] = image
					}
					
					//Callback on the UI thread.
					DispatchQueue.main.async {
						callback(image)
					}
				}
			}).resume() //DataTasks are initialized in a "paused" state.
		}
	}
}

class Section: NSObject {
	
	//NOTE ON CELL ID: Cell identifier can be set for the section, the row, both or neither. Priority goes to the cellId for the row, then the section.  If neither are set it defaults to "cell."
	//If the majority of rows in a section have the same cell identifier, set the cellId in section. Then on those rows that have a unique identifier, set the proper identifier on the row.
	
	var title: String?      //The title for a section
	var height: CGFloat?    //The height for a section header
	var cellId: String?     //The cell identifier for a section. See NOTE ON CELL ID above
	var rows: [Row]         //The rows for a section
	
	//Initialize a section. All values are optional and default to nil except rows
	init(title: String? = nil, height: CGFloat? = nil, cellId: String? = nil, rows: [Row]) {
		self.title = title
		self.height = height
		self.cellId = cellId
		self.rows = rows
	}
}

class Row: NSObject {
	
	var text: String?               //The text for a given row
	var detailText: String?         //The detail text for a given row
    var placeholderText: String?    //The placeholder text for an editable row
	var imageUrl: String?
	var cellId: String?             //The cell identifier for a given row. See NOTE ON CELL ID above
	var action: (() -> Void)?       //The action for a given row, ie. what a row will do when selected (does not need to be set for segues set in the storyboard)
	var enabled: Bool               //Whether a user interaction is enabled for a given row. Defaults to true
	var height: CGFloat?            //The height for a given row.
	var object: Any?                //An object for a given row. This allows tableData to save objects like ComputerLab.
	var moreInfo: [String: Any]?    //A dictionary of unique information for a given row. This allows a feature to save anything else they think important e.g. a URL
	
	//Initialize a row. All values are optional except enabled which defaults to true
    init(text: String? = nil, detailText: String? = nil, placeholderText: String? = nil, imageUrl: String? = nil, cellId: String? = nil, action: (() -> Void)? = nil, enabled: Bool = true, height: CGFloat? = nil, object: Any? = nil, moreInfo: [String: Any]? = nil) {
		self.text = text
		self.detailText = detailText
        self.placeholderText = placeholderText
		self.imageUrl = imageUrl
		self.cellId = cellId
		self.action = action
		self.enabled = enabled
		self.height = height
		self.object = object
		self.moreInfo = moreInfo
	}
}

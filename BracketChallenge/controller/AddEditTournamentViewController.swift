//
//  AddEditTournamentViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 2/11/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

private let DATE_FORMAT = DateFormatter.defaultDateFormat("MMM dd, yyyy")
private let DEFAULT_START = Date().next("Sunday")
private let DEFAULT_END = DEFAULT_START.next("Sunday")

private let TEXT_FIELD_SECTION = 0
private let DATE_SECTION = 1

class AddEditTournamentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UITextFieldDelegate {

    //MARK: Outlets
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: Public properties
    var tournament: Tournament?
    
    //MARK: Private properties
    private var tableData = TableData()
    private var datePickerIndexPath: IndexPath?
	private var selectedTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = tournament?.name ?? "Create Tournament"
        
        tableData = TableData(sections: [
            Section(cellId: "textFieldCell", rows: [
				Row(text: tournament?.name, placeholderText: "Tournament Name"),
				Row(text: tournament?.drawsUrl, placeholderText: "Draws URL"),
				Row(text: tournament?.imageUrl, placeholderText: "Image URL")
            ]),
            Section(cellId: "dateCell", rows: [
                Row(text: "Start Date", detailText: DATE_FORMAT.string(from: tournament?.startDate ?? DEFAULT_START)),
                Row(text: "End Date", detailText: DATE_FORMAT.string(from: tournament?.endDate ?? DEFAULT_END))
            ])
        ])
    }
    
    //MARK: UITableViewDataSource/Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.numberOfRows(inSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableData.row(forIndexPath: indexPath)
        let cell = tableData.cell(forTableView: tableView, atIndexPath: indexPath)
        if let cell = cell as? TextFieldTableViewCell {
			cell.textField.text = row.text
            cell.textField.placeholder = row.placeholderText
			cell.textField.delegate = self
        } else if let cell = cell as? DatePickerTableViewCell, let date = getDateFromRow(aboveIndexPath: indexPath) {
            cell.datePicker.date = date
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableData.cellId(forIndexPath: indexPath) == "dateCell" {
			//Make the text field disappear
			selectedTextField?.resignFirstResponder()
			
            tableView.beginUpdates()
            
            let insert: ((IndexPath, IndexPath) -> Void) = { selectedIndexPath, displayIndexPath in
                self.datePickerIndexPath = displayIndexPath
                self.tableData.sections[indexPath.section].rows.insert(Row(cellId: "datePickerCell"), at: displayIndexPath.row)
                self.tableView.insertRows(at: [displayIndexPath], with: .fade)
            }
            
            let delete: ((IndexPath, IndexPath) -> Void) = { selectedIndexPath, displayingIndexPath in
                self.datePickerIndexPath = nil
                self.tableData.sections[indexPath.section].rows.remove(at: displayingIndexPath.row)
                self.tableView.deleteRows(at: [displayingIndexPath], with: .fade)
            }
            
            //Already displaying a date
            if let displayingIndexPath = datePickerIndexPath {
                //Collapse the one displaying
                delete(indexPath, displayingIndexPath)
                
                //If they selected one that wasn't displaying, display it beneath
                if displayingIndexPath.row - 1 != indexPath.row {
                    insert(indexPath, IndexPath(row: indexPath.row + (displayingIndexPath.row > indexPath.row ? 1 : 0), section: indexPath.section))
                }
            } else {
                //Nothing displaying. Just insert beneath the selected row
                insert(indexPath, IndexPath(row: indexPath.row + 1, section: indexPath.section))
            }
            tableView.endUpdates()
		}
    }
	
	//MARK: UITextFieldDelegate
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		selectedTextField = textField
	}
    
    //MARK: Listeners
    
    @IBAction func pickerChanged(_ sender: UIDatePicker) {
        if var indexPath = datePickerIndexPath {
            indexPath.row -= 1
            tableData.row(forIndexPath: indexPath).detailText = DATE_FORMAT.string(from: sender.date)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if let newTournament = validateFields() {
            self.spinner.startAnimating()
            BCClient.saveTournament(tournament: newTournament, callback: { (tournament, error) in
                self.spinner.stopAnimating()
                if let tournament = tournament {
                    self.tournament = tournament
                    self.performSegue(withIdentifier: "unwind", sender: nil)
                } else {
                    super.displayAlert(error: error, alertHandler: nil)
                }
            })
        }
    }
	
	@IBAction func cancelTapped(_ sender: Any) {
		tournament = nil
		self.performSegue(withIdentifier: "unwind", sender: nil)
	}
    
    //MARK: Private functions
    
    private func getDateFromRow(aboveIndexPath indexPath: IndexPath) -> Date? {
        return DATE_FORMAT.date(from: tableData.row(forIndexPath: IndexPath(row: indexPath.row - 1, section: indexPath.section)).detailText)
    }
    
    private func validateFields() -> Tournament? {
        guard let name = getFieldText(forRow: 0) else { return nil }
        guard let drawsUrl = getFieldText(forRow: 1) else { return nil }
        guard let imageUrl = getFieldText(forRow: 2) else { return nil }
        
        let dates = tableData.rows(inSection: DATE_SECTION)
            .filter { $0.detailText != nil }
            .map { DATE_FORMAT.date(from: $0.detailText) }
        guard dates.count == 2 else { return nil }
        
		return Tournament(tournamentId: tournament?.tournamentId, name: name, masterBracketId: tournament?.masterBracketId, drawsUrl: drawsUrl, imageUrl: imageUrl, startDate: dates[0], endDate: dates[1])
    }
    
    private func getFieldText(forRow row: Int) -> String? {
        let text = (tableView.cellForRow(at: IndexPath(row: row, section: TEXT_FIELD_SECTION)) as? TextFieldTableViewCell)?.textField?.text
        return text != "" ? text : nil
    }
}

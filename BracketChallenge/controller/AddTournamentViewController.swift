//
//  AddTournamentViewController.swift
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

class AddTournamentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate {

    //MARK: Outlets
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: Public properties
    var createdTournament: Tournament?
    
    //MARK: Private properties
    private var tableData = TableData()
    private var datePickerIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableData = TableData(sections: [
            //TODD: Remove title?
            Section(cellId: "textFieldCell", rows: [
                Row(placeholderText: "Tournament Name"),
                Row(placeholderText: "Draws URL"),
                Row(placeholderText: "Image URL")
            ]),
            Section(cellId: "dateCell", rows: [
                Row(text: "Start Date", detailText: DATE_FORMAT.string(from: DEFAULT_START)),
                Row(text: "End Date", detailText: DATE_FORMAT.string(from: DEFAULT_END))
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
            cell.textField.placeholder = row.placeholderText
        } else if let cell = cell as? DatePickerTableViewCell, let date = getDateFromRow(aboveIndexPath: indexPath) {
            cell.datePicker.date = date
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableData.cellId(forIndexPath: indexPath) == "dateCell" {
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
    
    //MARK: Listeners
    
    @IBAction func pickerChanged(_ sender: UIDatePicker) {
        if var indexPath = datePickerIndexPath {
            indexPath.row -= 1
            tableData.row(forIndexPath: indexPath).detailText = DATE_FORMAT.string(from: sender.date)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if let tournament = validateFields() {
            self.spinner.startAnimating()
            BCClient.createTournament(tournament: tournament, callback: { (tournament, error) in
                self.spinner.stopAnimating()
                if let tournament = tournament {
                    self.createdTournament = tournament
                    self.performSegue(withIdentifier: "unwind", sender: nil)
                } else {
                    super.displayAlert(error: error, alertHandler: nil)
                }
            })
        }
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
        
        return Tournament(name: name, drawsUrl: drawsUrl, imageUrl: imageUrl, startDate: dates[0], endDate: dates[1])
    }
    
    private func getFieldText(forRow row: Int) -> String? {
        let text = (tableView.cellForRow(at: IndexPath(row: row, section: TEXT_FIELD_SECTION)) as? TextFieldTableViewCell)?.textField?.text
        return text != "" ? text : nil
    }
}

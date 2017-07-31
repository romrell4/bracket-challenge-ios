//
//  BCViewController.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class BCViewController: UIViewController {
    
    //MARK: - Methods
    
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
    
}

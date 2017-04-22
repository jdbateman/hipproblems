//
//  SortPickerViewController.swift
//  Hotelzzz
//
//  Created by john bateman on 4/21/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import UIKit

protocol SortPickerDelegate {
    func didSelectSortOption(sortOption: String)
}

class SortPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let sortOptions = ["name", "priceAscend", "priceDescend"] // todo: Enum?
    
    @IBOutlet weak var tableView: UITableView!
    
    var sortPickerDelegate:SortPickerDelegate?
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath) 
        
        // Configure the cell...
        configureCell(cell, row: indexPath.row)
        
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, row: Int) {
        
        DispatchQueue.main.async {
            cell.textLabel?.text = self.sortOptions[row]
        }
    }
    
    // MARK - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = sortPickerDelegate {
            delegate.didSelectSortOption(sortOption: self.sortOptions[indexPath.row])
        }
        self.dismiss(animated: true, completion: nil)
    }

}

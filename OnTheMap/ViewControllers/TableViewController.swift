//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/30/23.
//

import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    
    @IBOutlet weak var tableView: UITableView!
    
    // Brings us back to this view after dropping a pin on the map
    @IBAction func dismissPinDropView(unwindSegue: UIStoryboardSegue) {}

    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        MapClient.getStudentData() { success, error in
            if success {
                self.tableView.reloadData()
            } else {
                self.showAlert(title: "Student Data Unavailable", message: "The student data failed to load. Please try again later")
            }
        
        }
    }
    
    
    
    // MARK: Table View Functions
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of students: \(Students.onTheMap.count)")
        return Students.onTheMap.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell")!
        let student = Students.onTheMap[indexPath.row]
        
        cell.textLabel?.text = student.firstName + " " + student.lastName + ", " + student.mapString + ". Posted: " + student.updatedAt.formatted()
        
        
        return cell
    }
    
    
}

//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/30/23.
//
//  VC for table view that displays a list of past student locations
//

import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    // MARK: - Lifecycle Functions
    
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Load in an array of student locations to display in the table
        MapClient.getStudentData(completion: getStudentDataCompletion(success:error:))
    }
    
    
    
    // MARK: - IBActions
    
    
    // Brings us back to this view after user drops a pin on the map in PinDropView
    @IBAction func dismissPinDropView(unwindSegue: UIStoryboardSegue) {
        // Reload the array of student locations to update the table
        // Why does this not work?
        MapClient.getStudentData(completion: getStudentDataCompletion(success:error:))
    }

    
    
    // MARK: - Completion Handlers
    
    
    
    // Handles response from student data request
    func getStudentDataCompletion(success:Bool, error:Error?) {
        
        if success {
            self.tableView.reloadData()
        } else {
            print("\(String(describing: error))") // for debugging
            self.showAlert(title: "Student Data Unavailable", message: "The student data failed to load. Please try again later")
        }
    }
    
    
    func updateView() {
        
    }
    
    // MARK: - Table View Delegate Functions
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Students.onTheMap.count
    }
    
    
    // Load each table row with information to display about the corresponding student location
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell")!
        let student = Students.onTheMap[indexPath.row]
                
        if student.validURL { // Show icon to indicate the student has a valid link.
            
            let config = UIImage.SymbolConfiguration(scale: .medium)
            cell.imageView?.preferredSymbolConfiguration = config
            cell.imageView?.image = UIImage(systemName: "link")
        
        /*
         Wow, this really illustrates the fact that cells are recycled!
         If I don't assign nil to the image in an else statement here,
         scrolling down will show cells with a link icon that shouldn't have one.
         These are recycled cells that still have the icon attached.
         So I've got to be thourough, and not just add an icon when needed, but
         also make sure there is no icon present when there shouldn't be.
         */
            
        } else {
            cell.imageView?.image = nil
        }
        
        // Show student's name and location
        cell.textLabel?.text = student.firstName + " " + student.lastName + " - " + student.mapString
        return cell
    }
    
    
    // If user taps the table row, open its URL (where available) in prefered browser.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if Students.onTheMap[indexPath.row].validURL {
            let urlString = Students.onTheMap[indexPath.row].mediaURL
            if let url = URL(string:urlString) {
                UIApplication.shared.open(url)
            }
        }
    }
}

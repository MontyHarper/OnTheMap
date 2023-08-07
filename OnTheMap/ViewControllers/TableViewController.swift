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
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        super.viewWillAppear(true)
        
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
        return Students.onTheMap.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell")!
        let student = Students.onTheMap[indexPath.row]
                
        if student.validURL { // Indicate if the student has a valid link with an icon
            
            let config = UIImage.SymbolConfiguration(scale: .medium)
            cell.imageView?.preferredSymbolConfiguration = config
            cell.imageView?.image = UIImage(systemName: "link")
        
        /*
         Wow, this really illustrates the fact that cells are recycled!
         If I don't assign nil to the image in an else statement here,
         scrolling down will show cells with a link icon that shouldn't have one.
         These must be recycled cells that still have the icon attached.
         So I've got to be thourough, and not just add an icon when needed, but
         also make sure there is no icon where not needed.
         */
            
        } else {
            cell.imageView?.image = nil
        }
        
        // Show student's name and location
        cell.textLabel?.text = student.firstName + " " + student.lastName + " - " + student.mapString
        return cell
    }
    
    
    // If user taps the table row, open the URL in prefered browser.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if Students.onTheMap[indexPath.row].validURL {
            let urlString = Students.onTheMap[indexPath.row].mediaURL
            if let url = URL(string:urlString) {
                UIApplication.shared.open(url)
            }
        }
    }
}

//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Monty Harper on 8/1/23.
//

import Foundation
import UIKit


struct StudentLocation: Codable {
    var objectId: String
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    
    var nameAndLocation: String {
        return firstName + lastName + mapString
    }
    
    var validURL: Bool {
        if mediaURL != "" && (mediaURL.prefix(7) == "http://" || mediaURL.prefix(8) == "https://") {
            return true
        } else {
            return false
        }
    }
    
}

// Captures the server response.
struct StudentInformation: Codable {
    var results: [StudentLocation] = []
}

// Stores data for the app to display
// If we wanted to expand the app by showing different groups of students we could add variables to this struct for storing the different GET responses.
struct Students {
    static var onTheMap:[StudentLocation] = []
}


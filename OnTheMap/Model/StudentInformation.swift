//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Monty Harper on 8/1/23.
//
//  Structs for storing student location data.
//

import Foundation
import UIKit


// Use this struct to decode the student location data from JSON
// Represents a single student location.
struct StudentLocation: Codable {
    var objectId: String
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    
    // Used to determine if two data points are really the same.
    var nameAndLocation: String {
        return firstName + lastName + mapString
    }
    
    // Used to determine whether a location includes a useable URL
    var validURL: Bool {
        if mediaURL != "" && (mediaURL.prefix(7) == "http://" || mediaURL.prefix(8) == "https://") {
            return true
        } else {
            return false
        }
    }
    
}

// Captures the server's initial response.
struct StudentInformation: Codable {
    var results: [StudentLocation] = []
}

// Use to store all student locations in a single array.
// If we wanted to expand the app by showing different groups of students we could add variables to this struct for storing the different GET responses in different arrays.
struct Students {
    static var onTheMap:[StudentLocation] = []
}


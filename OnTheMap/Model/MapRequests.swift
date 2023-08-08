//
//  MapRequests.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/31/23.
//
//  Structs storing data structures for requests.
//

import Foundation


struct SessionRequest: Codable {
    var udacity: [String : String]
    
    init(username: String, password: String) {
        self.udacity = ["username" : username, "password" : password]
    }
    
}

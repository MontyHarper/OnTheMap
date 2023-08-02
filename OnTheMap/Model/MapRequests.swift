//
//  MapRequests.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/31/23.
//

import Foundation


struct SessionRequest: Codable {
    var udacity: [String : String]
    
    init(username: String, password: String) {
        self.udacity = ["username" : username, "password" : password]
    }
    
}

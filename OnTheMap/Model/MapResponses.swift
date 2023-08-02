//
//  MapAPI.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/31/23.
//

import Foundation


// Decode json response for opening a session...
struct SessionResponse: Codable {
    let account: Account
    let session: Session
}

struct Account: Codable {
    let registered: Bool
    let key: String
}

struct Session: Codable {
    let id: String
    let expiration: String
}



// Decode json response for nex thing...

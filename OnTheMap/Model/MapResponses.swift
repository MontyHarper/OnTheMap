//
//  MapAPI.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/31/23.
//
//  Structs storing data structures for responses.
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

// This one went unused, but here it is in case we need it in updates...
struct PostStudentLocationResponse: Codable {
    let createdAt: Date
    let objectID: String
}





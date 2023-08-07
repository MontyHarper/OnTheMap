//
//  MapResponses.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/31/23.
//
//  This class contains all the networking functionality.
//

import Foundation

class MapClient {
    
    
    // MARK: Properties
    
    // Stores credentials
    struct Auth {
        static var sessionID = ""
    }
    
    
    // Provides URLs needed to make specific requests
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/"
        
        // Types of requests
        case openSession
        case getStudentLocations
        case logout
        case dropPin
        
        // Calculates the url to use for each request
        var URLString: String {
            
            switch self {
            case .openSession: return Endpoints.base + "v1/session"
            case .getStudentLocations: return Endpoints.base + "v1/StudentLocation?limit=100&order=-updatedAt"
            case .logout: return Endpoints.base + "v1/session"
            case .dropPin: return Endpoints.base + "v1/StudentLocation"
            }
            
        }
        
        /*
         Converts a URL string (see above) to an actual URL.
         To retrieve the URL for a request:
         MapClient.Endpoints.<request type>.url
         */
        var url: URL {
            return URL(string: URLString)!
        }
    }
    
    
    
    class func getStudentData(completion: @escaping (Bool,Error?) -> Void) {
        
        let request = URLRequest(url: MapClient.Endpoints.getStudentLocations.url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) {data, response, error in
            if let data = data {
                
                let decoder = JSONDecoder()
                do {
                    let results = try decoder.decode(StudentInformation.self, from: data)
                    
                    Students.onTheMap = process(results.results)
                    
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                    return
                    
                } catch {
                    // The data doesn't fit our response pattern
                    // print(String(data: data, encoding: .utf8))
                    
                    fatalError("The student locations were unable to be stored due to an error in the code.")
                }
                
            } else { // Handle error...
                print("data is nil")
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            
        }
        task.resume()
        
    }
    
    
    /*
     I made a choice to clean up the list below. It was full of duplicate entries and partial entries.
     We were to show the most recent 100 entries, and this will reduce the number shown on screen, so it's possible this violates one of the requirements.
     I can alter this function to return the original array if necessary.
     I also may alter it to filter out more listings, for example some of them are just a first name, and some of them list non-locations like "a".
     */
    
    class func process(_ array:[StudentLocation]) -> [StudentLocation] {
        
        // Return a cleaned-up array of student locations.
        // This function will remove duplicate student locations, plus any locations missing a student name.
        
        var newArray = [StudentLocation]()
        var remove = false
        
        for testLocation in array {
            
            for location in newArray {
                if location.nameAndLocation == testLocation.nameAndLocation {
                    remove = true
                }
            }
            
            if (testLocation.firstName.count <= 2 && testLocation.lastName.count <= 2) || testLocation.mapString.count <= 2 {
                remove = true
            }
            
            if !remove {
                newArray.append(testLocation)
            } else {
                remove = false
            }
            
        }
        
        return newArray
    }
    
    class func postStudentLocation(pin: StudentLocation, completion: @escaping (Bool,Error?) -> Void) {
        
        var request = URLRequest(url: MapClient.Endpoints.dropPin.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(pin)
        } catch {
            print("Error - failed to parse json request into http body.")
            completion (false, error)
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                completion(false, error!)
            }
            print(String(data: data!, encoding: .utf8)!)
            completion(true, nil)
            
        }
        task.resume()
    }
    
    
}

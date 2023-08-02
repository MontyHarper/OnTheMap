//
//  MapResponses.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/31/23.
//

import Foundation

class MapClient {
    
    
    // Store credentials
    struct Auth {
        static var sessionID = ""
    }
    
    // Store URLs needed to make specific requests
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/"
        
        // Types of requests
        case openSession
        case getStudentLocations
        
        // Calculates the url to use for each request
        var URLString: String {
            
            switch self {
            case .openSession: return Endpoints.base + "v1/session"
            case .getStudentLocations: return Endpoints.base + "v1/StudentLocation?limit=100&order=-updatedAt"
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
                    Students.onTheMap = results.results
                    print("Student data: \(Students.onTheMap)")
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
}

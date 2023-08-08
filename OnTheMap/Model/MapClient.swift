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
    
    
    // MARK: - Properties
    
    // Stores credentials
    struct Auth {
        static var sessionID = ""
        static var userFirstName = ""
        static var userLastName = ""
    }
    
    
    /*
     Provides URLs needed to make specific requests.
     To retrieve the URL for a request use:
     MapClient.Endpoints.<request type>.url
     */
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/"
        
        // Types of requests
        case openSession
        case fetchUserName
        case getStudentLocations
        case logout
        case dropPin
        
        // Calculates the url to use for each request
        var URLString: String {
            switch self {
            case .openSession: return Endpoints.base + "v1/session"
            case .fetchUserName: return Endpoints.base + "v1/users/\(Auth.sessionID)"
            case .getStudentLocations: return Endpoints.base + "v1/StudentLocation?limit=100&order=-updatedAt"
            case .logout: return Endpoints.base + "v1/session"
            case .dropPin: return Endpoints.base + "v1/StudentLocation"
            }
        }
        
        // Converts the URL string from above to an actual URL.
        var url: URL {
            return URL(string: URLString)!
        }
    }
    
    
    
    // Set up notification center and notifications
    
    static let nc = NotificationCenter.default
    
    enum Notifications: String {
        case pinAdded = "UserHasAddedPinToMap"
        case newData = "NewDataIsAvailable"
    }
    
    
    // Set up error messages for login, to differentiate between possible errors.
    enum loginMessage: Error {
        case badCredentials
        case networkError
        
        var title: String {
            switch self {
            case .badCredentials:
                return "Incorrect Username or Password"
            case .networkError:
                return "Network Error"
            }
        }
        
        var description: String {
            switch self {
            case .badCredentials:
                return "Please check your spelling and try again."
            case .networkError:
                return "Please check your connection and try again later."
            }
        }
    }

    
    
    // MARK: Network Request Functions
    
    
    
    // MARK: Login
    
    // Logs the user into the app by retrieving a session ID.
    
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        
        // Set up a request
        var request = URLRequest(url: MapClient.Endpoints.openSession.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode the body of the request as a json object.
        do {
            request.httpBody = try JSONEncoder().encode(SessionRequest(username: username, password: password))
        } catch {
            // JSON Encoding failed; this is a coding error
            fatalError("Login was unable to be attempted due to an error in the code.")
            
        }
        
        // Set up a session and task
        let session = URLSession.shared
        let task = session.dataTask(with: request) {data, response, error in
            
            if let data = data {
                let range = 5..<data.count
                let newData = data.subdata(in: range) // *subset response data!* /
                
                // Decode the JSON response
                let decoder = JSONDecoder()
                do {
                    MapClient.Auth.sessionID = try decoder.decode(SessionResponse.self, from: newData).session.id
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                } catch {
                    // The data doesn't fit our response pattern.
                    // This probably means the credentials were wrong and the server is returning an error.
                    DispatchQueue.main.async {
                        completion(false, MapClient.loginMessage.badCredentials)
                    }
                }
            } else {
                // The response data was nil.
                // This is probably a network connection error.
                DispatchQueue.main.async {
                    completion(false, MapClient.loginMessage.networkError)
                }
            }
        }
        task.resume()
    }
    
    
    // MARK: - Fetch User Name
    
    // Retrieves first and last name of user
    class func fetchUserName(completion: @escaping (Bool,Error?) -> Void) {
        
        // Set up request, session, task
        let request = URLRequest(url: MapClient.Endpoints.fetchUserName.url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            // If data is returned, trim off the nonsense at the beginning
            if let data = data {
                let range = 5..<data.count
                let newData = data.subdata(in: range)
                
                // Decode JSON response
                let decoder = JSONDecoder()
                do {
                    let results = try decoder.decode(UserData.self, from: newData)
                    
                    // Store user name
                    Auth.userLastName = results.last_name
                    Auth.userFirstName = results.first_name
                    
                    // Success!
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                } catch {
                    // The data doesn't fit our response pattern
                    completion(false, error)
                }
            } else {
                // request failed
                completion(false,error)
            }
        }
        task.resume()
    }
    
    
    // MARK: - Retrieve Student Locations
    
    // Retrieves an array of student locations.
    class func getStudentData(completion: @escaping (Bool,Error?) -> Void) {
        
        // Set up request, session and task
        let request = URLRequest(url: MapClient.Endpoints.getStudentLocations.url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) {data, response, error in
            if let data = data {
                
                // Decode JSON response
                let decoder = JSONDecoder()
                do {
                    let results = try decoder.decode(StudentInformation.self, from: data)
                    
                    // Store student locations
                    Students.onTheMap = process(results.results)
                    
                    // Success!
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                    return
                    
                } catch {
                    // The data doesn't fit our response pattern
                    fatalError("The student locations were unable to be stored due to an error in the code.")
                }
                
            } else {
                // Data is nil
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
        }
        task.resume()
    }
    
   
    
    // MARK: - Post a Pin
    
    class func postStudentLocation(pin: StudentLocation, completion: @escaping (Bool,Error?) -> Void) {
        
        // Set up request
        var request = URLRequest(url: MapClient.Endpoints.dropPin.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(pin)
        } catch {
            // Failed to parse results
            completion (false, error)
        }
        
        // Run the task
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                // Failed
                completion(false, error!)
            }
            // Success!
            completion(true, nil)
        }
        task.resume()
    }
    
    
    
    // MARK: - Logout
    
    class func logout(completion: @escaping (Bool) -> Void) {
        
        // Set up the url request and task
        var request = URLRequest(url: MapClient.Endpoints.logout.url)
        request.httpMethod = "DELETE"
        
        // Not sure what this cookie stuff is doing, but I copied it from the Udacity instructions...
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        // Call the session
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            if error != nil {
                // Failed
                DispatchQueue.main.async {
                    return completion(false)
                }
            }
            // verify logout
            let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            print(String(data: newData!, encoding: .utf8)!)
            DispatchQueue.main.async {
                return completion(true)
            }
        }
        task.resume()
    }
    
    
    // MARK: - Data Processing
    
    /*
     I made a choice to clean up the list using the function below.
     The data was full of duplicate entries and partial entries.
     (Now that I've been testing the drop a pin function I can see why!)
     */
    
    class func process(_ array:[StudentLocation]) -> [StudentLocation] {
        
        // Return a cleaned-up array of student locations.
        // This function will remove duplicate student locations, plus any locations missing a student name.

        var newArray = [StudentLocation]()
        var remove = false
        
        // Test each location in the array
        for testLocation in array {
            
            // Remove the location if it's a repeat
            for location in newArray {
                if location.nameAndLocation == testLocation.nameAndLocation {
                    remove = true
                }
            }
            
            // Remove the location if it doesn't really have a person or place name
            if (testLocation.firstName.count <= 2 && testLocation.lastName.count <= 2) || testLocation.mapString.count <= 2 {
                remove = true
            }
            
            // Keep the location if we aren't removing it
            if !remove {
                newArray.append(testLocation)
            } else {
                remove = false
            }
        }
        
        return newArray
    }
    
}

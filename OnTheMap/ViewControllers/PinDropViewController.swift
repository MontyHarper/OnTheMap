//
//  PinDropViewController.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/30/23.
//
//  This VC allows users to enter a location and URL and drop a new pin on the map
//

import CoreLocation
import Foundation
import MapKit
import UIKit

class PinDropViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    
    //MARK: - Properties
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var currentLocation = ""
    var geoLocation = CLLocationCoordinate2D()
    
    
    
    //MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        submitButton.isEnabled = false
        locationField.delegate = self
        urlField.delegate = self
        mapView.delegate = self
        
    }
    
    
    
    //MARK: - IBActions
    
    // Dismiss the VC when the user taps "Cancel."
    @IBAction func dismissPinDropViewController(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    
    // Post a new pin when the user taps "Submit."
    @IBAction func postMyPin(_ sender: Any) {
        
        let myPin = StudentLocation(
            objectId: "abcd",
            uniqueKey: "1234",
            firstName: MapClient.Auth.userFirstName,
            lastName: MapClient.Auth.userLastName,
            mapString: currentLocation,
            mediaURL: urlField.text ?? "",
            latitude: geoLocation.latitude,
            longitude: geoLocation.longitude
        )
        
        MapClient.postStudentLocation(pin:myPin, completion: handlePostPinResponse(success:error:))
    }
    
    
    func handlePostPinResponse(success:Bool, error:Error?) {
        
        if error != nil {
            showAlert(title: "Pin Failed", message: "Sorry, your pin failed to post. Please try again.", completion: {self.dismiss(animated:true)})
        } else {
            showAlert(title: "Pin Posted! 😎", message: "Thank you for posting a pin!", completion: {
                
                // Shout it to the world - the user has posted a pin!
                // This triggers the table VC to refresh the data from the server.
                MapClient.nc.post(name: Notification.Name(MapClient.Notifications.pinAdded.rawValue), object: nil)
                self.dismiss(animated:true)
            })
        }
    }
    
    
    
    // MARK: - Text field delegate methods

    // When a location is submitted from the keyboard, attempt to geolocate and place a pin on the map.
    func textFieldDidEndEditing(_ textField: UITextField) {
                
        /*
         Do nothing if:
         - The text field that finished editing is not the locationField
         - The location entered is the same as the one we already have
         - The location entered is empty
         */
        if textField != locationField || textField.text == currentLocation || !nonemptyString(textField.text) {
            return
            
        } else {
            // Let the geolocation begin!
            submitButton.isEnabled = false
            currentLocation = textField.text ?? ""
            activityIndicator.startAnimating()
            
            // Geocode the location string...
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(currentLocation, completionHandler: GCHandler(placemarks:error:))
        }
    }
    
    
    // Dismisses the keyboard when the user hits return.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    // MARK: - Completion Handlers
    
        func GCHandler(placemarks: [CLPlacemark]?, error: Error?) {
                                
                if error != nil {
                    
                    self.showAlert(title: "Error Retrieving Location", message: "Your location could not be retrieved at this time. Please check your spelling and try again.")
                    
                } else {
                    
                    if let places = placemarks {
                        
                        // Geocoder may return multiple locations...
                        switch places.count {
                            
                        case 0:
                            // Not sure this will ever occurr - if placemarks isn't nil why would it be an empty array?
                            self.showAlert(title: "Location Not Found", message: "Please check your spelling and try again.")
                            
                        case 1:
                            // We have success!
                            geoLocation = places[0].location!.coordinate
                            addToMap(places[0])
                            submitButton.isEnabled = true
                            
                            
                        default:
                            // Multiple locations in the result
                            self.showAlert(title: "Multiple Locations Found", message: "Please try again with a more specific description of your location.")
                        }
                        
                    } else {
                        // Result is nil.
                        self.showAlert(title: "Location Does Not Seem to Exist", message: "Please try again with a different description.")
                    }
                }
            activityIndicator.stopAnimating()
            }
    
    
    
    // MARK: - Private Functions
    
    // Adds the entered location to the map, if geolocate is successful.
    func addToMap(_ pin:CLPlacemark) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.location!.coordinate
        annotation.title = "You Are Here"
        let region = MKCoordinateRegion(center: annotation.coordinate, span: (MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)))
        self.mapView.setRegion(region, animated: true)
        self.mapView.addAnnotations([annotation])
    }
    
    
}

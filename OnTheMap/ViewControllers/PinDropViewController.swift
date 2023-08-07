//
//  PinDropViewController.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/30/23.
//

import CoreLocation
import Foundation
import MapKit
import UIKit

class PinDropViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    
    //MARK: Properties
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var currentLocation = ""
    var geoLocation = CLLocationCoordinate2D()
    
    
    //MARK: Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        submitButton.isEnabled = false
        locationField.delegate = self
        urlField.delegate = self
        mapView.delegate = self
        
    }
    
    
    //MARK: IBActions
    
    @IBAction func dismissPinDropViewController(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    
    @IBAction func postMyPin(_ sender: Any) {
        
        let myPin = StudentLocation(
            objectId: "abcd",
            uniqueKey: "1234",
            firstName: "Bartholomew",
            lastName: "Cubbins",
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
            showAlert(title: "Pin Posted! 😎", message: "Thank you for posting a pin!", completion: {self.dismiss(animated:true)})
        }
        
    }
    
    
    //MARK: Text field delegatem methods

    // When a location is submitted from the keyboard, attempt to geolocate and place a pin on the map.
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        print("Text field did end editing has been called!!")
        
        /*
         Do nothing if:
         - The text field we're looking at is not the locationField
         - The location entered is the same as the one we already have
         - The location entered is empty
         */
        if textField != locationField || textField.text == currentLocation || textField.text == "" || textField.text == nil {
            print("text does not meet requirements, returning with no action")
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
    
    
    
        func GCHandler(placemarks: [CLPlacemark]?, error: Error?) {
                                
                print("geocoder has returned a result: \(placemarks)")
                if error != nil {
                    
                    print("there is an error in the result: \(error)")
                    self.showAlert(title: "Error Retrieving Location", message: "Your location could not be retrieved at this time. Please check your spelling and try again.")
                    
                } else {
                    
                    print("geocoder has not returned an error")
                    if let places = placemarks {
                        
                        print("placemarks is not nil")
                        switch places.count {
                            
                        case 0:
                            print("case 0")
                            // Not sure this will ever occurr - if placemarks isn't nil why would it be an empty array?
                            self.showAlert(title: "Location Not Found", message: "Please check your spelling and try again.")
                            
                        case 1:
                            print("case 1: \(places[0])")
                            // We have success!
                            geoLocation = places[0].location!.coordinate
                            addToMap(places[0])
                            submitButton.isEnabled = true
                            
                            
                        default:
                            print("case default")
                            self.showAlert(title: "Multiple Locations Found", message: "Please try again with a more specific description of your location.")
                        }
                        
                    } else {
                        print("placemarks is nil")
                        self.showAlert(title: "Location Does Not Seem to Exist", message: "Please try again with a different description.")
                    }
                    
                }
            activityIndicator.stopAnimating()
            }
    
    
    
    
    func addToMap(_ pin:CLPlacemark) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.location!.coordinate
        annotation.title = "You Are Here"
        let region = MKCoordinateRegion(center: annotation.coordinate, span: (MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)))
        self.mapView.setRegion(region, animated: true)
        self.mapView.addAnnotations([annotation])
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

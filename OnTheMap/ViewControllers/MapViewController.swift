//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/30/23.
//
//  VC for Map view that displays a pin for each student location.
//

import Foundation
import MapKit
import UIKit


class MapViewController: UIViewController, MKMapViewDelegate {
    
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    // MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load pins onto map showing student locations
        showMapPins()
        
        // Reload pins when new data is available
        MapClient.nc.addObserver(self, selector: #selector(showMapPins), name: Notification.Name(MapClient.Notifications.newData.rawValue), object: nil)
        
    }
    
    // MARK: - IBActions
    
    // Brings us back to this view after user drops a pin on the map in PinDropView
    // Does this even get used?
    @IBAction func dismissPinDropView(unwindSegue: UIStoryboardSegue) {}
    
    
    
    // MARK: - Private Methods
    
    @objc func showMapPins() {
        // Set up an array of annotations to load onto the map as pins
        var annotations:[MKPointAnnotation] = []
        
        for student in Students.onTheMap {
            
            var annotation = MKPointAnnotation()
            annotation.title = student.firstName + " " + student.lastName
            annotation.subtitle = student.validURL ? student.mediaURL : "No Link Available"
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(student.latitude), longitude: CLLocationDegrees(student.longitude))
            
            // Filter out any locations with latitude and longitude zero, assuming those are invalid locations.
            if annotation.coordinate.latitude != 0.0 || annotation.coordinate.longitude != 0.0 {
                
                annotations.append(annotation)
            }
        }
        
        self.mapView.addAnnotations(annotations)
    }
   
    
    
    // MARK: - Map Delegate Functions

    // Returns an MLAnnotationView to show additional information on each pin when it's tapped.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        pinView!.annotation = annotation
        
        pinView!.rightCalloutAccessoryView?.isHidden = (pinView!.annotation?.subtitle == "No Link Available")
        pinView!.rightCalloutAccessoryView?.isUserInteractionEnabled = (pinView!.annotation?.subtitle != "No Link Available")
        
        return pinView
    }
    
    
    // Opens a browser to the URL indicated when a pin's info button is tapped.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        guard view.annotation?.subtitle == "No Link Available" else {
            
            if control == view.rightCalloutAccessoryView {
                if let urlString = view.annotation?.subtitle! {
                    UIApplication.shared.open(URL(string:urlString)!)
                }
            }
            return
        }
        return
    }
    
}

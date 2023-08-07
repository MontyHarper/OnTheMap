//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/30/23.
//

import Foundation
import MapKit
import UIKit


class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func dismissPinDropView(unwindSegue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                print(annotation)
                print(annotation.title)
                print(annotation.subtitle)
                print(annotation.coordinate)
            }
        }
        
        self.mapView.addAnnotations(annotations)
        print("\(annotations.count) map pins should be showing.")
    }

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

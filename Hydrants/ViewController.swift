//
//  ViewController.swift
//  Hydrants
//
//  Created by Paul Baker on 3/26/19.
//  Copyright © 2019 Paul Baker. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate,
UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    @IBOutlet var hydrantMap: MKMapView!
    
    var hydrantStore: HydrantStore?
    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for permission to track the user location
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.requestWhenInUseAuthorization()
        hydrantMap!.delegate = self
        
        for hydrant in hydrantStore!.hydrantUpdates {
            let annotation = HydrantAnnotation(hydrant: hydrant)
            hydrantMap.addAnnotation(annotation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) { if status == .authorizedWhenInUse {
        hydrantMap.showsUserLocation = true
        locationManager!.startUpdatingLocation() // Updates as the app runs
    } else {
        print("Location not permitted for app - TODO show dialog for user")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        centerMapOnUserLocation() // Follow user on map as they move
    }
    
    // Centers map on the user
    func centerMapOnUserLocation() {
        if let location = locationManager!.location {
            hydrantMap.setCenter(location.coordinate, animated: true)
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters:50000,
                                            longitudinalMeters: 50000)
            hydrantMap.setRegion(region, animated: true)
        } else {
            print("No location available")
        }
    
    }
    
    // Button that adds hydrant
    @IBAction func addHydrantUpdate(_ sender: UIBarButtonItem) {
        
        centerMapOnUserLocation()
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .savedPhotosAlbum
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        picker.dismiss(animated: true, completion: nil)
        
        let alertController = UIAlertController(title: "Enter Comments", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Add optional comment"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let comment = alertController.textFields!.first!.text
            let hydrantUpdate = HydrantUpdate(coordinate: (self.locationManager?.location?.coordinate)!, comment: comment)
            self.hydrantStore!.addHydrantUpdate(hydrant: hydrantUpdate, image: image)
            let annotation = HydrantAnnotation(hydrant: hydrantUpdate)
            self.hydrantMap.addAnnotation(annotation)
        }
        
        let cancelAciton = UIAlertAction(title: "Cancel", style: .default)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAciton)
        
        present(alertController, animated: true)
    }
    
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is HydrantAnnotation {
            
            let hydrantAnnotation = annotation as! HydrantAnnotation
            let pinAnnotationView = MKPinAnnotationView()
            pinAnnotationView.annotation = hydrantAnnotation
            pinAnnotationView.canShowCallout = true
            
            let image = hydrantStore!.getImage(forKey: hydrantAnnotation.hydrant.imageKey)
            
            let photoView = UIImageView()
            photoView.contentMode = .scaleAspectFit
            photoView.image = image
            let heightConstraint = NSLayoutConstraint(item: photoView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
            photoView.addConstraint(heightConstraint)
            
            pinAnnotationView.detailCalloutAccessoryView = photoView
            
            return pinAnnotationView
        }
        
        return nil
        
    }
    
}


//
//  MapViewController.swift
//  Cardial_Example
//
//  Created by Renato Cardial on 3/15/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import MapKit
import Cardial

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var annotation = MKPointAnnotation()
    
    private lazy var location: LocationService =  {
        //You can instantiate without delegate and watch responses with closures "updatedLocation" and "requestStatus"
        //let loc = LocationService(typeRequest: .authorizedWhenInUse)
        
        let loc = LocationService(typeRequest: .authorizedWhenInUse, delegate: self)
        return loc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnnotation()
        location.start()
        
//      //If you instantiate LocationService without delegate, you can call this closures to get responses
//        location.updatedLocation { [weak self] (latitude, longitude) in
//            self?.putOnMap(latitude: latitude, longitude: longitude)
//        }
//
//        location.requestStatus { (allowed, status) in
//            printText(allowed ? "Conceded Permission" : "Not allowed")
//        }
        
    }
    
    deinit {
        printText("Dealloc MapViewController")
    }
    
}

extension MapViewController: LocationServiceDelegate {
    
    func locationError(error: Error) {
        printText(error.localizedDescription)
    }
    
    func updatedLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.putOnMap(latitude: latitude, longitude: longitude)
    }
    
    func requestStatus(allowed: Bool, status: CLAuthorizationStatus) {
        
        if !allowed && status == .denied {
            let alert = UIAlertController(title: "Warning", message: "You not enabled permission for your location, please authorize this permission in Application settings", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK" , style: .default, handler: { [weak self] (action) in
                if !(self?.location.openSettings() ?? false) {
                    printText("Please, go to Settings of the App to enable Location Authorization")
                }
            })
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true)
        }
        
        printText(allowed ? "Conceded Permission" : "Not allowed")
    }
    
}


extension MapViewController {
    
    func putOnMap(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        
        annotation.coordinate = center
        if mapView.annotations.count == 0 {
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func setupAnnotation() {
        annotation.title = "You"
        annotation.subtitle = "Current location"
    }
}

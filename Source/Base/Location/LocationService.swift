//
//  Location.swift
//  Cardial
//
//  Created by Renato Cardial on 3/15/20.
//

import Foundation
import CoreLocation

public protocol LocationServiceDelegate: class {
    func updatedLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    func requestStatus(allowed: Bool, status: CLAuthorizationStatus)
    func locationError(error: Error)
}

public class LocationService: NSObject, CLLocationManagerDelegate, PermissionProtocol {
    
    private weak var delegate: LocationServiceDelegate?
    
    private var updatedLocationClosure: ((CLLocationDegrees, CLLocationDegrees) -> Void)?
    private var requestStatusClosure: ((Bool, CLAuthorizationStatus) -> Void)?
    
    private var locationManager: CLLocationManager?
    private var typeRequest: CLAuthorizationStatus = .authorizedWhenInUse
    
    private var locationStarted: Bool = false
    private var locationRequested: Bool = false
    
    public init(typeRequest: CLAuthorizationStatus, delegate: LocationServiceDelegate? = nil) {
        super.init()
        self.typeRequest = typeRequest
        self.setupManager()
        self.delegate = delegate
    }
    
    private func setupManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    public func havePermission() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    return false
                case .authorizedAlways, .authorizedWhenInUse:
                    return true
                @unknown default:
                break
            }
        }
        return false
    }
    
    public func setupRequest(accuracy: CLLocationAccuracy, typeRequest: CLAuthorizationStatus = .authorizedWhenInUse) {
        self.locationManager?.desiredAccuracy = accuracy
        self.typeRequest = typeRequest
    }
    
    public func start() {
        if havePermission() {
            locationStarted = true
            locationManager?.startUpdatingLocation()
        } else {
            requestPermission()
        }
    }
    
    public func stop() {
        locationStarted = false
        locationManager?.stopUpdatingLocation()
    }
    
    public func isStarted() -> Bool {
        return locationStarted
    }
    
    public func updatedLocation(completion: @escaping ((CLLocationDegrees, CLLocationDegrees) -> Void)) {
        updatedLocationClosure = completion
    }
    
    public func requestStatus(completion: @escaping (Bool, CLAuthorizationStatus) -> Void) {
        requestStatusClosure = completion
    }
    
    public func requestPermission() {
        locationRequested = true
        switch typeRequest {
        case .authorizedAlways:
            locationManager?.requestAlwaysAuthorization()
            break
        default:
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        let allowed = (status == .authorizedAlways || status == .authorizedWhenInUse) ? true :  false
        if status != .notDetermined {
            
            if locationRequested {
                locationRequested = false
                if let delegate = self.delegate {
                    delegate.requestStatus(allowed: allowed, status: status)
                } else {
                    requestStatusClosure?(allowed, status)
                }
            }
            
            if allowed {
                start()
            }
        }
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            if let delegate = self.delegate {
                delegate.updatedLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            } else {
                updatedLocationClosure?( location.coordinate.latitude, location.coordinate.longitude)
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        delegate?.locationError(error: error)
    }
    
    deinit {
        locationManager?.stopUpdatingLocation()
        printText("Dealloc LocationService")
    }
    
}

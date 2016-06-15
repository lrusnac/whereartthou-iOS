//
//  RoomDetailViewController.swift
//  whereartthou
//
//  Created by Leonid Rusnac on 14/06/16.
//  Copyright © 2016 Leonid Rusnac. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation
import Alamofire

class RoomDetailViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var room: Room? = nil

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }

    // JUST reminder how to add pins on the map
    // mapView.addOverlay(MKCircle(centerCoordinate: location2D, radius: 100 as CLLocationDistance))
    // let annotation = LocationPin(coordinate: location2D)
    // mapView.addAnnotation(annotation)

    override func viewDidLoad() {
        super.viewDidLoad()

        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self

            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestAlwaysAuthorization()
        }

        // set the pooling for other people locations in the same room
        // https://where.artthou.net/rest/v1/room/github/latest
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        // print("lon: \(currentLocation?.longitude), lat: \(currentLocation?.latitude)")
        
        // /rest/v1/room/:sid/user/:uid/pos/:lat/:lon/:timestamp
        print("https://where.artthou.net/rest/v1/room/\(room!.name!)/user/leo/pos/\(location.coordinate.latitude)/\(location.coordinate.longitude)/\(UInt64(NSDate().timeIntervalSince1970*1000))")
        
        Alamofire.request(.GET, "https://where.artthou.net/rest/v1/room/\(room!.name!)/user/leo/pos/\(location.coordinate.latitude)/\(location.coordinate.longitude)/\(UInt64(NSDate().timeIntervalSince1970*1000))")
            .responseJSON { response in switch response.result {
            case .Success:
                print("success")
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
        

        mapView.setCenterCoordinate(location.coordinate, animated: true)
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)), animated: true)

        // send the location to rest api
    }
}

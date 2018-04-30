//
//  ViewController.swift
//  SilverBell
//
//  Created by Jackson Rossborough on 4/28/18.
//  Copyright © 2018 Jackson Rossborough. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import CoreLocation

class ListMapVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var caretakers = [Caretaker]()
    var userLocation = CLLocationCoordinate2D()
    var distances = [CLLocationDistance]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let group1 = DispatchGroup()
        let group2 = DispatchGroup()
        var deltaLat = CLLocationDegrees()
        var deltaLong = CLLocationDegrees()
        
        group1.enter()
        if let id = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(id).child("AdditionalInfo").observeSingleEvent(of: .value, with: { (snapshot) in
                if let data = snapshot.value as? [String: Any]{
                    let lat = data["Latitude"] as! Double
                    let long = data["Longitude"] as! Double
                    self.userLocation = CLLocationCoordinate2D.init(latitude: lat, longitude: long)
                    group1.leave()
                }
            })
        }
        group1.notify(queue: DispatchQueue.main) {
            let maxDistance = self.distances.max()
            let maxDistanceIndex = self.distances.index(of: maxDistance!)
            group2.enter()
            Database.database().reference().child("caretakers").child(self.caretakers[maxDistanceIndex!].id).child("AdditionalInfo").observeSingleEvent(of: .value, with: { (snapshot) in
                if let data = snapshot.value as? [String: Any]{
                    let lat = data["Latitude"] as! Double
                    let long = data["Longitude"] as! Double
                    deltaLat = abs(lat - self.userLocation.latitude)
                    deltaLong = abs(long - self.userLocation.longitude)
                    group2.leave()
                }
            })
            group2.notify(queue: DispatchQueue.main) {
                let span = MKCoordinateSpanMake(deltaLat, deltaLong)
                let region = MKCoordinateRegion(center: self.userLocation, span: span)
                self.mapView.setRegion(region, animated: true)
                Caretaker.getPlacemarks(caretakers: self.caretakers, completion: { (placemarks) in
                    self.mapView.addAnnotations(placemarks)
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

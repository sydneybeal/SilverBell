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
    var userCoordinates = CLLocationCoordinate2D()
    var distances = [CLLocationDistance]()
    var selectedCaretaker: Caretaker?
    
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
                    self.userCoordinates = CLLocationCoordinate2D.init(latitude: lat, longitude: long)
                    let userLocation = UserLocation.init(coordinate: self.userCoordinates, title: "My Address")
                    self.mapView.addAnnotation(userLocation)
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
                    deltaLat = abs(lat - self.userCoordinates.latitude)
                    deltaLong = abs(long - self.userCoordinates.longitude)
                    group2.leave()
                }
            })
            group2.notify(queue: DispatchQueue.main) {
                let span = MKCoordinateSpanMake(deltaLat + 0.05, deltaLong + 0.15)
                let region = MKCoordinateRegion(center: self.userCoordinates, span: span)
                self.mapView.setRegion(region, animated: true)
                Placemarks.getPlacemarks(caretakers: self.caretakers, completion: { (Placemarks) in
                    self.mapView.addAnnotations(Placemarks)
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToCaretaker" {
            let vc = segue.destination as! CaretakerProfileVC
            vc.profile = self.selectedCaretaker
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ListMapVC: MKMapViewDelegate {
    // 1
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? Placemarks else { return nil }
        // 3
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.glyphText = String(annotation.position)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Placemarks
        self.selectedCaretaker = location.caretaker
        self.performSegue(withIdentifier: "mapToCaretaker", sender: self)
    }
}

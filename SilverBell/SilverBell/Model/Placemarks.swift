//
//  Placemarks.swift
//  SilverBell
//
//  Created by Jackson Rossborough on 4/29/18.
//  Copyright © 2018 Jackson Rossborough. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class Placemarks: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let position: Int
    let subtitle: String?
    let caretaker: Caretaker
    //let caretaker: Caretaker
    //let position: Int
    
    
    class func getPlacemarks(caretakers: [Caretaker], completion: @escaping ([Placemarks]) -> Swift.Void) {
        let ref = Database.database().reference()
        let placemarksGroup = DispatchGroup()
        var placemarks = [Placemarks]()
        
        placemarksGroup.enter()
        for i in 0...(caretakers.count-1) {
            placemarksGroup.enter()
            ref.child("caretakers").child(caretakers[i].id).child("AdditionalInfo").observeSingleEvent(of: .value, with: { (snapshot) in
                if let data = snapshot.value as? [String: Any]{
                    let lat = data["Latitude"] as! Double
                    let long = data["Longitude"] as! Double
                    let coordinates = CLLocationCoordinate2D.init(latitude: lat, longitude: long)
                    let placemark = MKPlacemark.init(coordinate: coordinates)
                    let Placemark = Placemarks.init(coordinate: coordinates, title: caretakers[i].name, subtitle: placemark.title!, position: i+1, caretaker: caretakers[i])
                    placemarks.append(Placemark)
                    placemarksGroup.leave()
                } else {
                    placemarksGroup.leave()
                }
            })
        }
        placemarksGroup.leave()
        placemarksGroup.notify(queue: DispatchQueue.main) {
            completion(placemarks)
        }
    }
    
    
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, position: Int, caretaker: Caretaker) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.position = position
        self.caretaker = caretaker
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

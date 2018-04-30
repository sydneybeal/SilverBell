//
//  UserLocation.swift
//  SilverBell
//
//  Created by Jackson Rossborough on 4/30/18.
//  Copyright © 2018 Jackson Rossborough. All rights reserved.
//

import UIKit
import MapKit

class UserLocation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    let title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.coordinate = coordinate
        self.title = title
        
        super.init()
    }
}

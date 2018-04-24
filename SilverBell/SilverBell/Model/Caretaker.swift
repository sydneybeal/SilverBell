//
//  Caretakers.swift
//  SilverBell
//
//  Created by Jackson Rossborough on 1/31/18.
//  Copyright © 2018 Jackson Rossborough. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation

class Caretaker: NSObject {
    
    //MARK: Properties
    let name: String
    let email: String
    let id: String
    var profilePic: UIImage
    var rating: Int
    
    //MARK: Methods
    class func registerCaretaker(withName: String, email: String, password: String, profilePic: UIImage, rating: Int, completion: @escaping (Bool) -> Swift.Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (caretaker, error) in
            if error == nil {
                caretaker?.sendEmailVerification(completion: nil)
                let storageRef = Storage.storage().reference().child("caretakersProfilePics").child(caretaker!.uid)
                let imageData = UIImageJPEGRepresentation(profilePic, 0.1)
                storageRef.putData(imageData!, metadata: nil, completion: { (metadata, err) in
                    if err == nil {
                        let path = metadata?.downloadURL()?.absoluteString
                        let values = ["name": withName, "email": email, "profilePicLink": path!, "rating": rating] as [AnyHashable : Any]
                        Database.database().reference().child("caretakers").child((caretaker?.uid)!).child("credentials").updateChildValues(values, withCompletionBlock: { (errr, _) in
                            if errr == nil {
                                let userInfo = ["email": email, "password": password, "caretaker": true] as [String : Any]
                                UserDefaults.standard.set(userInfo, forKey: "userInformation")
                                completion(true)
                            }
                        })
                    }
                })
            }
            else {
                completion(false)
            }
        })
    }
    
    class func additionalCaretakerInfo(uid: String, lat: Double, long: Double, phone: String, completion: @escaping (Bool) -> Swift.Void) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let update = ["Latitude": lat,
                      "Longitude": long,
                      "Phone Number": phone] as [String : Any]
        let childUpdates = ["caretakers/\(uid)/AdditionalInfo": update]
        ref.updateChildValues(childUpdates, withCompletionBlock: { (errr, _) in
            if errr == nil{
                completion(true)
            }
        })
    }
    
    class func loginCaretaker(withEmail: String, password: String, completion: @escaping (Bool) -> Swift.Void) {
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (caretaker, error) in
            if error == nil {
                let userInfo = ["email": withEmail, "password": password, "caretaker": true] as [String : Any]
                UserDefaults.standard.set(userInfo, forKey: "userInformation")
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    class func logOutUser(completion: @escaping (Bool) -> Swift.Void) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "userInformation")
            completion(true)
        } catch _ {
            completion(false)
        }
    }
    
    class func info(forUserID: String, completion: @escaping (Caretaker) -> Swift.Void) {
        Database.database().reference().child("caretakers").child(forUserID).child("credentials").observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [AnyHashable: Any]{
                let name = data["name"]!
                let email = data["email"]!
                let rating = data["rating"] as! Int
                let link = URL.init(string: data["profilePicLink"] as! String)
                URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                    if error == nil {
                        let profilePic = UIImage.init(data: data!)
                        let caretaker = Caretaker.init(name: name as! String, email: email as! String, id: forUserID, profilePic: profilePic!, rating: rating)
                        completion(caretaker)
                    }
                }).resume()
            }
        })
    }
    
    class func downloadAllCaretakers(exceptID: String, completion: @escaping (Caretaker) -> Swift.Void) {
        Database.database().reference().child("caretakers").observe(.childAdded, with: { (snapshot) in
            let id = snapshot.key
            let data = snapshot.value as! [String: Any]
            if data["credentials"] != nil {
                let credentials = data["credentials"] as! [AnyHashable: Any]
                if id != exceptID {
                    let name = credentials["name"]!
                    let email = credentials["email"]!
                    let link = URL.init(string: credentials["profilePicLink"]! as! String)
                    let rating = credentials["rating"] as! Int
                    URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                        if error == nil {
                            let profilePic = UIImage.init(data: data!)
                            let caretaker = Caretaker.init(name: name as! String, email: email as! String, id: id, profilePic: profilePic!, rating: rating)
                            completion(caretaker)
                        }
                    }).resume()
                }
            }
        })
    }
    
    class func getCaretakerCount(completion: @escaping (Int) -> Swift.Void) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("caretakers").observeSingleEvent(of: .value, with: {(snapshot) in
        if let data = snapshot.value as? String {
            let numCaretakers = data.count
            completion(numCaretakers)
            }
        })
    }
    
    class func sortCaretakersByLocation(caretakers: [Caretaker], uidUser: String, completion: @escaping ([Caretaker],[CLLocationDistance]) -> Swift.Void) {
        var distances = [CLLocationDistance()]
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("users").child(uidUser).child("AdditionalInfo").observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [AnyHashable: Any]{
                let lat = data["Latitude"]
                let long = data["Longitude"]
                let userLocation = CLLocation.init(latitude: lat as! CLLocationDegrees, longitude: long as! CLLocationDegrees)
                for caretaker in caretakers {
                    ref.child("caretakers").child(caretaker.id).child("AdditionalInfo").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let data = snapshot.value as? [AnyHashable: Any]{
                            let lat = data["Latitude"]
                            let long = data["Longitude"]
                            let location = CLLocation.init(latitude: lat as! CLLocationDegrees, longitude: long as! CLLocationDegrees)
                            distances.append(location.distance(from: userLocation))
                        }
                    })
                }
            }
        })
        let combined = zip(distances, caretakers).sorted(by: {$0.0 < $1.0})
        let sortedCaretakers = combined.map {$0.1}
        let sortedDistances = combined.map {$0.0}
        completion(sortedCaretakers,sortedDistances)
    }
    
    class func checkCaretakerVerification(completion: @escaping (Bool) -> Swift.Void) {
        Auth.auth().currentUser?.reload(completion: { (_) in
            let status = (Auth.auth().currentUser?.isEmailVerified)!
            completion(status)
        })
    }
    
    
    
    //MARK: Inits
    init(name: String, email: String, id: String, profilePic: UIImage, rating: Int) {
        self.name = name
        self.email = email
        self.id = id
        self.profilePic = profilePic
        self.rating = rating
    }
}

//  MIT License

//  Copyright (c) 2017 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import Foundation
import UIKit
import Firebase
import CoreLocation

class User: NSObject {
    
    //MARK: Properties
    let name: String
    let email: String
    let id: String
    var profilePic: UIImage
    var rating: Int
    
    //MARK: Methods
    class func registerUser(withName: String, email: String, password: String, profilePic: UIImage, rating: Int, completion: @escaping (Bool) -> Swift.Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                var userCount = 0
                let myGroup = DispatchGroup()
                
                myGroup.enter()
                Database.database().reference().child("Counts").observeSingleEvent(of: .value, with: { (snapshot) in
                    let data = snapshot.value as! [String: Int]
                    userCount = data["Users"]!
                    userCount += 1
                    myGroup.leave()
                })
                
                myGroup.notify(queue: DispatchQueue.main) {
                Database.database().reference().child("Counts").updateChildValues(["Users": userCount], withCompletionBlock: { (errr, _) in
                    if errr == nil {
                        user?.sendEmailVerification(completion: nil)
                        let storageRef = Storage.storage().reference().child("usersProfilePics").child(user!.uid)
                        let imageData = UIImageJPEGRepresentation(profilePic, 0.1)
                        storageRef.putData(imageData!, metadata: nil, completion: { (metadata, err) in
                            if err == nil {
                                let path = metadata?.downloadURL()?.absoluteString
                                let values = ["name": withName, "email": email, "profilePicLink": path!, "rating": rating] as [AnyHashable : Any]
                                Database.database().reference().child("users").child((user?.uid)!).child("credentials").updateChildValues(values, withCompletionBlock: { (errr, _) in
                                    if errr == nil {
                                        let userInfo = ["email": email, "password": password, "caretaker": false] as [String : Any]
                                        UserDefaults.standard.set(userInfo, forKey: "userInformation")
                                        completion(true)
                                    }
                                })
                            }
                        })
                    }
                })
                }
            }
            else {
                completion(false)
            }
        })
    }
    
    class func additionalUserInfo(uid: String, lat: Double, long: Double, phone: String, completion: @escaping (Bool) -> Swift.Void) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let update = ["Latitude": lat,
                      "Longitude": long,
                      "Phone Number": phone] as [String : Any]
        let childUpdates = ["users/\(uid)/AdditionalInfo": update]
        ref.updateChildValues(childUpdates, withCompletionBlock: { (errr, _) in
            if errr == nil{
                completion(true)
            }
        })
    }

    
    class func loginUser(withEmail: String, password: String, completion: @escaping (Bool) -> Swift.Void) {
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (user, error) in
            if error == nil {
                let userInfo = ["email": withEmail, "password": password, "caretaker": false] as [String : Any]
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
    
    class func info(forUserID: String, completion: @escaping (User) -> Swift.Void) {
        Database.database().reference().child("users").child(forUserID).child("credentials").observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [AnyHashable: Any]{
                let name = data["name"]!
                let email = data["email"]!
                let rating = data["rating"] as! Int
                let link = URL.init(string: data["profilePicLink"] as! String)
                URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                    if error == nil {
                        let profilePic = UIImage.init(data: data!)
                        let user = User.init(name: name as! String, email: email as! String, id: forUserID, profilePic: profilePic!, rating: rating)
                        completion(user)
                    }
                }).resume()
            }
        })
    }
    
    class func downloadAllUsers(exceptID: String, completion: @escaping (User) -> Swift.Void) {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
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
                            let user = User.init(name: name as! String, email: email as! String, id: id, profilePic: profilePic!, rating: rating)
                            completion(user)
                        }
                    }).resume()
                }
            }
        })
    }
    
    
    class func checkUserVerification(completion: @escaping (Bool) -> Swift.Void) {
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


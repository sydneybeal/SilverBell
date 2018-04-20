//
//  Request.swift
//  
//
//  Created by Jackson Rossborough on 4/9/18.
//

import Foundation
import UIKit
import Firebase

class Request: NSObject {
    
    // MARK: PROPERTIES
    let tag: String
    let uidUser: String
    let uidCaretaker: String
    let date: String
    let time: String
    let additionalInfo: String
    let accepted: Bool
    
    
    // MARK: METHODS
    
    class func createRequest(uidUser: String, uidCaretaker: String, date:String, time: String, additionalInfo: String, completion: @escaping (Bool) -> Swift.Void){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let accepted = false
        let tag = ref.child("users").child(uidUser).child("requests").childByAutoId().key
        let request = ["uidUser": uidUser,
                       "uidCaretaker": uidCaretaker,
                       "Date": date,
                       "Time": time,
                       "Info": additionalInfo,
                       "Accepted": accepted] as [String : Any]
        let childUpdates = ["users/\(uidUser)/requests/\(tag)": request,
                            "/Allrequests/\(tag)": request,
                            "caretakers/\(uidCaretaker)/requests/\(tag)": request]
        ref.updateChildValues(childUpdates, withCompletionBlock: { (errr, _) in
            if errr == nil{
            }
        })
    }
    
    class func acceptRequest(tag: String, uidUser: String, uidCaretaker: String, completion: @escaping (Bool) -> Swift.Void){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let childUpdates = ["users/\(uidUser)/requests/\(tag)/Accepted": true,
                            "/Allrequests/\(tag)/Accepted": true,
                            "caretakers/\(uidCaretaker)/requests/\(tag)/Accepted": true]
        ref.updateChildValues(childUpdates, withCompletionBlock: { (errr, _) in
            if errr == nil{
                completion(true)
            }
        })
    }
    
    class func downloadAllRequestsUser(uidUser: String, completion: @escaping (Request) -> Swift.Void){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("users").child(uidUser).child("requests").observe(.childAdded, with: { (snapshot) in
            let tag = snapshot.key
            let data = snapshot.value as! [String: Any]
            let uidCaretaker = data["uidCaretaker"]!
            let uidUser = data["uidUser"]!
            let date = data["Date"]!
            let time = data["Time"]!
            let info = data["Info"]!
            let accepted = data["Accepted"]!
            let request = Request.init(tag: tag , uidUser: uidUser as! String, uidCaretaker: uidCaretaker as! String, date: date as! String, time: time as! String, additionalInfo: info as! String, accepted: accepted as! Bool)
            completion(request)
        })
    }
    
    class func downloadAllRequestsCaretaker(uidCaretaker: String, completion: @escaping (Request) -> Swift.Void){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("caretakers").child(uidCaretaker).child("requests").observeSingleEvent(of: .value, with: { (snapshot) in
            let tag = snapshot.key
            let data = snapshot.value as! [String: Any]
            let uidCaretaker = data["uidCaretaker"]!
            let uidUser = data["uidUser"]!
            let date = data["Date"]!
            let time = data["Time"]!
            let info = data["Info"]!
            let accepted = data["Accepted"]!
            let request = Request.init(tag: tag , uidUser: uidUser as! String, uidCaretaker: uidCaretaker as! String, date: date as! String, time: time as! String, additionalInfo: info as! String, accepted: accepted as! Bool)
            completion(request)
        })
    }
    
    
    // MARK: INITS
    init(tag: String, uidUser: String, uidCaretaker: String, date:String, time: String, additionalInfo: String, accepted: Bool) {
        self.tag = tag;
        self.uidUser = uidUser;
        self.uidCaretaker = uidCaretaker;
        self.date = date;
        self.time = time;
        self.additionalInfo = additionalInfo;
        self.accepted = accepted;
    }
}

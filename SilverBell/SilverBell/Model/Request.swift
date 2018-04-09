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
    
    
    // MARK: METHODS
    
    class func createRequest(uidUser: String, uidCaretaker: String, date:String, time: String, additionalInfo: String, completion: @escaping (Bool) -> Swift.Void){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let tag = ref.child("users").child(uidUser).child("requests").childByAutoId().key
        let request = ["uidUser": uidUser,
                       "uidCaretaker": uidCaretaker,
                       "Date": date,
                       "Time": time,
                       "Info": additionalInfo]
        let childUpdates = ["/requests/\(tag)": request]
        ref.child("users").child(uidUser).updateChildValues(childUpdates, withCompletionBlock: { (errr, _) in
            if errr == nil{
                    let childUpdates = ["/Allrequests/\(tag)": request]
                    ref.updateChildValues(childUpdates, withCompletionBlock: { (errr, _) in
                    if errr == nil{
                        completion(true)
                        }
                })
            }
        })
    }
    
    
    // MARK: INITS
    init(tag:String, uidUser: String, uidCaretaker: String, date:String, time: String, additionalInfo: String) {
        self.tag = tag;
        self.uidUser = uidUser;
        self.uidCaretaker = uidCaretaker;
        self.date = date;
        self.time = time;
        self.additionalInfo = additionalInfo;
    }
}

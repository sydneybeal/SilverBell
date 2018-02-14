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

class Caretakers {
    let user: User
    var lastMessage: Message
    
    class func showCaretakers(completion: @escaping ([Caretakers]) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            var caretakers1 = [Caretakers]()
            Database.database().reference().child("users").child(currentUserID).child("conversations").observe(.childAdded, with: { (snapshot) in
                if snapshot.exists() {
                    let fromID = snapshot.key
                    let values = snapshot.value as! [String: String]
                    let location = values["location"]!
                    User.info(forUserID: fromID, completion: { (user) in
                        let emptyMessage = Message.init(type: .text, content: "loading", owner: .sender, timestamp: 0, isRead: true)
                        let caretakers = Caretakers.init(user: user, lastMessage: emptyMessage)
                        caretakers1.append(caretakers)
                        caretakers.lastMessage.downloadLastMessage(forLocation: location, completion: {
                            completion(caretakers1)
                        })
                    })
                }
            })
        }
    }
    
    //MARK: Inits
    init(user: User, lastMessage: Message) {
        self.user = user
        self.lastMessage = lastMessage
    }
}

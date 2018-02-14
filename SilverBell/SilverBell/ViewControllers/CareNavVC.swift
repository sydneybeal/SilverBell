//
//  CareNavVC.swift
//  SilverBell
//
//  Created by Jackson Rossborough on 1/31/18.
//  Copyright © 2018 Jackson Rossborough. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class CareNavVC: UINavigationController {
    /*
    var items = [User]()
    
    func customization() {
        self.fetchUsers()
    }
    
    func fetchUsers()  {
        if let id = Auth.auth().currentUser?.uid {
            User.downloadAllUsers(exceptID: id, completion: {(user) in
                DispatchQueue.main.async {
                    self.items.append(user)
                    //self.tableView.reloadData()
                }
            })
        }
    }
    
    func fetchUserInfo() {
        if let id = Auth.auth().currentUser?.uid {
            User.info(forUserID: id, completion: {[weak weakSelf = self] (user) in
                DispatchQueue.main.async {
                    //weakSelf?.nameLabel.text = user.name
                    //weakSelf?.emailLabel.text = user.email
                    //weakSelf?.profilePicView.image = user.profilePic
                    weakSelf = nil
                }
            })
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CaretakerTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CaretakerTableViewCell  else {
            fatalError("The dequeued cell is not an instance of CaretkaerTableViewCell.")
        }
        let item = items[indexPath.row]
        cell.nameLabel.text = item.name
        cell.profilePic.image = item.profilePic
        
        return cell
    }
    */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.view.transform = CGAffineTransform.identity
    }
}

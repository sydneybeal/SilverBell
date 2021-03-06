//
//  TableViewController.swift
//  SilverBell
//
//  Created by Jackson Rossborough on 4/9/18.
//  Copyright © 2018 Jackson Rossborough. All rights reserved.
//

import UIKit
import Firebase

class RequestHistoryTableVC: UITableViewController {

    var items = [Request]()
    var selectedRequest: Request?
    var caretakerItems = [Caretaker]()
    var selectedCaretaker: Caretaker?
    
    @IBOutlet var RequestHistoryTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            self.fetchRequests()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // print(items.count)
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RequestHistoryViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RequestHistoryViewCell  else {
            fatalError("The dequeued cell is not an instance of RequestHistoryViewCell.")
        }
        let item = items[indexPath.row]
        let caretakerItem = caretakerItems[indexPath.row]
        let status: String
        cell.nameLabel.text = caretakerItem.name
        cell.dateLabel.text = item.date
        cell.timeLabel.text = item.time
        cell.profilePic.image = caretakerItem.profilePic
        if (item.accepted == true) {
            status = "Accepted"
        } else {
            status = "Open"
        }
        cell.statusLabel.text = status
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.items.count > 0 {
            self.selectedRequest = self.items[indexPath.row]
            self.selectedCaretaker = self.caretakerItems[indexPath.row]
            self.performSegue(withIdentifier: "requestSegue", sender: self)
        }
    }
    
    func customization() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushToCaretakerProfile(notification:)), name: NSNotification.Name(rawValue: "showRequest"), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "requestSegue" {
            let vc = segue.destination as! RequestVC
            vc.request = self.selectedRequest
            vc.caretaker = self.selectedCaretaker
        }
    }
    
    
    func fetchRequests()  {
        if let id = Auth.auth().currentUser?.uid {
            Request.downloadAllRequestsUser(uidUser: id, completion: {(request) in
                    self.items.append(request)
                    Caretaker.info(forUserID: request.uidCaretaker, completion: {(caretaker) in
                        self.caretakerItems.append(caretaker)
                    })
            })
            self.reloadTable()
        }
    }
    
    func reloadTable() {
        if (self.caretakerItems.count != self.items.count || self.items.count == 0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reloadTable()
            }
        }
        if (self.caretakerItems.count == self.items.count) {
            DispatchQueue.main.async {
                self.RequestHistoryTableView.reloadData()
            }
        }
    }
    
    @objc func pushToCaretakerProfile(notification: NSNotification) {
        if let request = notification.userInfo?["request"] as? Request {
            self.selectedRequest = request
            self.performSegue(withIdentifier: "requestSegue", sender: self)
        }
    }

}

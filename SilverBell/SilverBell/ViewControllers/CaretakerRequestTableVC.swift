//
//  CaretakerRequestTableVC.swift
//  
//
//  Created by Jackson Rossborough on 4/13/18.
//

import UIKit
import Firebase

class CaretakerRequestTableVC: UITableViewController {

    var items = [Request]()
    var selectedRequest: Request?
    var userItems = [User]()
    var selectedUser: User?
    
    @IBOutlet var RequestHistoryTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRequests()
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
        let userItem = userItems[indexPath.row]
        let status: String
        cell.nameLabel.text = userItem.name
        cell.dateLabel.text = item.date
        cell.timeLabel.text = item.time
        cell.profilePic.image = userItem.profilePic
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
            self.performSegue(withIdentifier: "caretakerRequestSegue", sender: self)
        }
    }
    
    func customization() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushToCaretakerProfile(notification:)), name: NSNotification.Name(rawValue: "showRequest"), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "caretakerRequestSegue" {
            let vc = segue.destination as! CaretakerRequestVC
            vc.request = self.selectedRequest
            vc.user = self.selectedUser
        }
    }
    
    func fetchRequests()  {
        if let id = Auth.auth().currentUser?.uid {
            Request.downloadAllRequestsCaretaker(uidUser: id, completion: {(request) in
                DispatchQueue.main.async {
                    self.items.append(request)
                    User.info(forUserID: request.uidUser, completion: {(user) in
                        DispatchQueue.main.async {
                            self.userItems.append(user)
                            self.RequestHistoryTableView.reloadData()
                        }
                    })
                }
            })
        }
    }
    
    @objc func pushToCaretakerProfile(notification: NSNotification) {
        if let request = notification.userInfo?["request"] as? Request {
            self.selectedRequest = request
            self.performSegue(withIdentifier: "caretakerRequestSegue", sender: self)
        }
    }

}
